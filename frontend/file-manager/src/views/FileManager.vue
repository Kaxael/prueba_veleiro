<template>
  <div class="app-container">
    <div class="main-content">
      <div class="header">
        <h1>Gestor de Archivos</h1>
      </div>

      <template v-if="!selectedFolder">
        <div class="folder-actions">
          <input
            type="text"
            v-model="newRootFolderName"
            placeholder="Nombre de nueva carpeta raíz"
            @keyup.enter="createFolder(null)"
            class="folder-input"
          >
          <button class="btn btn-create" @click="createFolder(null)">
            <i class="fas fa-plus"></i> Crear Carpeta Raíz
          </button>
        </div>

        <FolderList
          :folders="rootFolders"
          @select="selectFolder"
          @move="showMoveDialog"
          @delete="deleteFolder"
        />
      </template>

      <!-- Vista de Contenido de Carpeta -->
      <template v-else>
        <div class="breadcrumbs">
          <span @click="goToRoot"><i class="fas fa-home"></i> Inicio</span>
          <span v-for="(crumb, index) in breadcrumbs" :key="index">
            > <span @click="navigateTo(crumb)">{{ crumb.name }}</span>
          </span>
        </div>

        <div class="folder-actions">
          <input
            type="text"
            v-model="newSubfolderName"
            placeholder="Nombre de nueva subcarpeta"
            @keyup.enter="createFolder(selectedFolder.id)"
            class="folder-input"
          >
          <button class="btn btn-create" @click="createFolder(selectedFolder.id)">
            <i class="fas fa-folder-plus"></i> Crear Subcarpeta
          </button>
        </div>

        <FolderContent
          :folders="childFolders"
          :files="files"
          @select-folder="selectFolder"
          @move="handleMoveItem"
          @delete-folder="handleDeleteFolder"
          @delete-file="handleDeleteFile"
        />

        <div class="upload-section">
          <input
            type="file"
            id="file-upload"
            @change="onFileChange"
            style="display: none"
          >
          <label for="file-upload" class="btn btn-upload">
            <i class="fas fa-upload"></i> Seleccionar Archivo
          </label>
          <input
            type="text"
            v-model="fileName"
            placeholder="Nombre del archivo (opcional)"
            class="file-name-input"
          >
          <button class="btn btn-primary" @click="uploadFile" :disabled="!fileToUpload">
            <i class="fas fa-check"></i> Subir Archivo
          </button>
           <div v-if="selectedFile" class="file-metadata-panel">
      <div class="panel-header">
        <h3>Detalles del Archivo</h3>
        <button class="btn-close" @click="selectedFile = null">
          <i class="fas fa-times"></i>
        </button>
      </div>
      
      <div class="panel-content">
        <div class="metadata-row">
          <span class="metadata-label">Nombre:</span>
          <span class="metadata-value">{{ selectedFile.name }}</span>
        </div>
        
        <div class="metadata-row">
          <span class="metadata-label">Tipo:</span>
          <span class="metadata-value">{{ getFileType(selectedFile.name) }}</span>
        </div>
        
        <div class="metadata-row">
          <span class="metadata-label">Subido:</span>
          <span class="metadata-value">{{ formatDate(selectedFile.uploaded_at) }}</span>
        </div>
        
        <div class="metadata-row">
          <span class="metadata-label">Tamaño:</span>
          <span class="metadata-value">{{ getFileSize(selectedFile.file) }}</span>
        </div>
        
        <div class="metadata-section" v-if="selectedFile.metadata">
          <h4>Metadatos:</h4>
          <div class="metadata-row" v-if="selectedFile.metadata.line_count">
            <span class="metadata-label">Líneas:</span>
            <span class="metadata-value">{{ selectedFile.metadata.line_count }}</span>
          </div>
          <div class="metadata-row" v-if="selectedFile.metadata.language">
            <span class="metadata-label">Idioma:</span>
            <span class="metadata-value">{{ selectedFile.metadata.language }}</span>
          </div>
          <div class="metadata-row" v-if="selectedFile.metadata.named_entities">
            <span class="metadata-label">Entidades:</span>
            <span class="metadata-value">{{ selectedFile.metadata.named_entities.join(', ') }}</span>
          </div>
        </div>
        
        <a :href="selectedFile.file" target="_blank" class="btn-download">
          <i class="fas fa-download"></i> Descargar Archivo
        </a>
      </div>
    </div>
        </div>
        
      </template>

      <MoveDialog
        v-if="showMoveModal"
        :current-item="{
          id: itemToMove.id,
          type: itemToMove.type,
          name: itemToMove.type === 'folder' 
            ? folders.find(f => f.id === itemToMove.id)?.name 
            : files.find(f => f.id === itemToMove.id)?.name
        }"
        :folders="folders"
        @move="handleConfirmMove"
        @close="showMoveModal = false"
      />
    </div>
  </div>
</template>

<script>
import axios from 'axios'
import FolderList from './FolderList.vue'
import FolderContent from './FolderContent.vue'
import MoveDialog from './MoveDialog.vue'

export default {
  components: {
    FolderList,
    FolderContent,
    MoveDialog
  },
  data() {
    return {
      folders: [],
      selectedFolder: null,
      files: [],
      newRootFolderName: '',
      newSubfolderName: '',
      fileName: '',
      fileToUpload: null,
      uploading: false,
      showMoveModal: false,
      itemToMove: null
    }
  },
  computed: {
    rootFolders() {
      return this.folders.filter(folder => folder.parent === null)
    },
    childFolders() {
      if (!this.selectedFolder) return []
      return this.folders.filter(folder => folder.parent === this.selectedFolder.id)
    },
    breadcrumbs() {
      if (!this.selectedFolder) return []
      
      const crumbs = []
      let current = this.selectedFolder
      
      while (current) {
        crumbs.unshift(current)
        current = this.folders.find(f => f.id === current.parent)
      }
      
      return crumbs
    },
    availableFolders() {
      // Todas las carpetas excepto la actual y sus descendientes
      return this.folders.filter(folder => {
        return folder.id !== this.itemToMove?.id && 
               !this.isDescendant(this.itemToMove?.id, folder.id)
      })
    }
  },
  methods: {
    async fetchFolders() {
      try {
        const { data } = await axios.get('/api/folders/')
        this.folders = data || []
      } catch (error) {
        console.error("Error fetching folders:", error)
        this.folders = []
      }
    },
    async fetchFiles(folderId) {
      try {
        const { data } = await axios.get(`/api/files/?folder=${folderId}`)
        this.files = data || []
      } catch (error) {
        console.error("Error fetching files:", error)
        this.files = []
      }
    },
    async createFolder(parentId) {
      const name = parentId ? this.newSubfolderName : this.newRootFolderName
      if (!name.trim()) return

      try {
        await axios.post('/api/folders/', { name, parent: parentId })
        if (parentId) {
          this.newSubfolderName = ''
        } else {
          this.newRootFolderName = ''
        }
        this.fetchFolders()
      } catch (error) {
        console.error("Error creating folder:", error)
      }
    },
    async deleteFolder(folder) {
      if (!confirm(`¿Eliminar la carpeta "${folder.name}" y todo su contenido?`)) return
      
      try {
        await axios.delete(`/api/folders/${folder.id}/`)
        this.fetchFolders()
        if (this.selectedFolder?.id === folder.id) {
          this.selectedFolder = null
        }
      } catch (error) {
        console.error("Error deleting folder:", error)
      }
    },
    async deleteFile(file) {
      if (!confirm(`¿Eliminar el archivo "${file.name}" permanentemente?`)) return
      
      try {
        await axios.delete(`/api/files/${file.id}/`)
        this.fetchFiles(this.selectedFolder.id)
      } catch (error) {
        console.error("Error deleting file:", error)
      }
    },
    selectFolder(folder) {
      this.selectedFolder = folder
      this.fetchFiles(folder.id)
    },
    goToRoot() {
      this.selectedFolder = null
    },
    navigateTo(folder) {
      this.selectFolder(folder)
    },
    showMoveDialog(item) {
      this.itemToMove = item
      this.showMoveModal = true
    },
    async handleMove(destinationId) {
      try {
        if (this.itemToMove.type === 'folder') {
          await axios.patch(`/api/folders/${this.itemToMove.id}/`, { 
            parent: destinationId 
          })
        } else {
          await axios.patch(`/api/files/${this.itemToMove.id}/`, { 
            folder: destinationId 
          })
        }
        
        this.fetchFolders()
        if (this.selectedFolder) {
          this.fetchFiles(this.selectedFolder.id)
        }
      } catch (error) {
        console.error("Error moving item:", error)
        alert("No se pudo completar la operación")
      } finally {
        this.showMoveModal = false
      }
    },
    isDescendant(ancestorId, descendantId) {
      if (!ancestorId || !descendantId) return false
      
      let currentId = descendantId
      while (currentId) {
        if (currentId === ancestorId) return true
        const folder = this.folders.find(f => f.id === currentId)
        currentId = folder?.parent
      }
      return false
    },
    onFileChange(event) {
      this.fileToUpload = event.target.files[0]
      if (!this.fileName && this.fileToUpload) {
        this.fileName = this.fileToUpload.name.split('.')[0]
      }
    },
    async uploadFile() {
      if (!this.fileToUpload) {
        alert('Por favor selecciona un archivo')
        return
      }
      
      this.uploading = true
      
      try {
        const formData = new FormData()
        formData.append('file', this.fileToUpload)
        formData.append('folder', this.selectedFolder.id)
        if (this.fileName) {
          formData.append('name', this.fileName)
        }
        
        await axios.post('/api/files/', formData, {
          headers: {
            'Content-Type': 'multipart/form-data'
          }
        })
        
        this.fileToUpload = null
        this.fileName = ''
        document.getElementById('file-upload').value = ''
        this.fetchFiles(this.selectedFolder.id)
      } catch (error) {
        console.error("Error uploading file:", error)
      } finally {
        this.uploading = false
      }
    },
    refresh() {
      this.fetchFolders()
      if (this.selectedFolder) {
        this.fetchFiles(this.selectedFolder.id)
      }
    },
     handleDeleteFolder(folder) {
    console.log('Carpeta a eliminar:', folder) /
    axios.delete(`/api/folders/${folder.id}/`)
      .then(() => {
        this.fetchFolders()
        if (this.selectedFolder?.id === folder.id) {
          this.selectedFolder = null
        }
      })
      .catch(error => {
        console.error("Error deleting folder:", error)
        alert("No se pudo eliminar la carpeta")
      })
  },

  
  handleDeleteFile(file) {
    console.log('Archivo a eliminar:', file) // Verifica en consola
    axios.delete(`/api/files/${file.id}/`)
      .then(() => {
        this.fetchFiles(this.selectedFolder.id)
      })
      .catch(error => {
        console.error("Error deleting file:", error)
        alert("No se pudo eliminar el archivo")
      })
  },

  handleMoveItem(item) {
    console.log('Item a mover:', item) 
    this.itemToMove = item
    this.showMoveModal = true
  },

  handleConfirmMove(destinationId) {
    const endpoint = this.itemToMove.type === 'folder' 
      ? `/api/folders/${this.itemToMove.id}/` 
      : `/api/files/${this.itemToMove.id}/`
    
    const data = this.itemToMove.type === 'folder'
      ? { parent: destinationId }
      : { folder: destinationId }

    axios.patch(endpoint, data)
      .then(() => {
        this.fetchFolders()
        if (this.selectedFolder) {
          this.fetchFiles(this.selectedFolder.id)
        }
      })
      .catch(error => {
        console.error("Error moving item:", error)
        alert("No se pudo completar el movimiento")
      })
      .finally(() => {
        this.showMoveModal = false
      })
  },
  getFileType(filename) {
      const extension = filename.split('.').pop().toUpperCase()
      const typeMap = {
        'TXT': 'Texto Plano',
        'CSV': 'Documento CSV',
        'PDF': 'Documento PDF',
        'DOC': 'Documento Word',
        'DOCX': 'Documento Word',
        'XLS': 'Hoja de Cálculo',
        'XLSX': 'Hoja de Cálculo',
        'JPG': 'Imagen JPEG',
        'PNG': 'Imagen PNG'
      }
      return typeMap[extension] || `Archivo ${extension}`
    },
    
    formatDate(dateString) {
      if (!dateString) return 'N/A'
      const options = { 
        year: 'numeric', 
        month: 'long', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }
      return new Date(dateString).toLocaleDateString('es-ES', options)
    },
    
    getFileSize(fileUrl) {
      
      return 'N/A'
    },
    selectFile(file) {
    this.selectedFile = file
  },
  },
  mounted() {
    this.fetchFolders()
  },
  async fetchFileMetadata(fileId) {
    try {
      const { data } = await axios.get(`/api/files/${fileId}/metadata/`)
      this.selectedFile.metadata = data
    } catch (error) {
      console.error("Error fetching file metadata:", error)
    }
  }
}
</script>

<style scoped>
.app-container {
  font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.main-content {
  background-color: #fff;
  border-radius: 8px;
  box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
  padding: 20px;
}

.header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
  padding-bottom: 15px;
  border-bottom: 1px solid #eee;
}

.header h1 {
  color: #333;
  font-size: 24px;
  margin: 0;
}

.folder-actions {
  display: flex;
  gap: 10px;
  margin-bottom: 20px;
}

.folder-input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
}

.breadcrumbs {
  margin-bottom: 15px;
  font-size: 15px;
}

.breadcrumbs span {
  cursor: pointer;
  color: #1976D2;
}

.breadcrumbs span:hover {
  text-decoration: underline;
}

.upload-section {
  margin-top: 25px;
  padding-top: 15px;
  border-top: 1px solid #eee;
  display: flex;
  gap: 10px;
  align-items: center;
}

.file-name-input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 4px;
}

.btn {
  padding: 10px 15px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s;
  border: none;
  display: flex;
  align-items: center;
  gap: 8px;
}

.btn-outline {
  background: transparent;
  border: 1px solid #ddd;
  color: #555;
}

.btn-outline:hover {
  border-color: #1976D2;
  color: #1976D2;
}

.btn-create {
  background-color: #4CAF50;
  color: white;
}

.btn-create:hover {
  background-color: #388E3C;
}

.btn-upload {
  background-color: #2196F3;
  color: white;
}

.btn-upload:hover {
  background-color: #1976D2;
}

.btn-primary {
  background-color: #FF9800;
  color: white;
}

.btn-primary:hover {
  background-color: #F57C00;
}

.btn-primary:disabled {
  background-color: #ccc;
  cursor: not-allowed;
}

.fas {
  margin-right: 5px;
}
.btn-action {
  opacity: 0.7;
  transition: opacity 0.2s;
}

.item:hover .btn-action {
  opacity: 1;
}

.btn-action:hover {
  transform: scale(1.1);
}

.btn-action i {
  font-size: 14px;
}

.file-metadata-panel {
  position: fixed;
  bottom: 20px;
  right: 20px;
  width: 350px;
  background: white;
  border-radius: 8px;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.panel-header {
  padding: 15px;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.panel-header h3 {
  margin: 0;
  font-size: 16px;
  color: #333;
}

.btn-close {
  background: none;
  border: none;
  font-size: 18px;
  cursor: pointer;
  color: #777;
}

.panel-content {
  padding: 15px;
  overflow-y: auto;
  flex-grow: 1;
}

.metadata-section {
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid #f0f0f0;
}

.metadata-section h4 {
  margin: 0 0 10px 0;
  font-size: 14px;
  color: #555;
}

.metadata-row {
  display: flex;
  margin-bottom: 10px;
}

.metadata-label {
  font-weight: 500;
  color: #555;
  width: 100px;
  flex-shrink: 0;
}

.metadata-value {
  color: #333;
  word-break: break-word;
}

.btn-download {
  display: inline-block;
  margin-top: 15px;
  padding: 8px 15px;
  background-color: #4CAF50;
  color: white;
  border-radius: 4px;
  text-decoration: none;
  font-size: 14px;
  text-align: center;
}

.btn-download:hover {
  background-color: #388E3C;
}

.btn-download i {
  margin-right: 8px;
}

/* Responsive */
@media (max-width: 768px) {
  .file-metadata-panel {
    width: calc(100% - 40px);
    left: 20px;
    right: 20px;
    bottom: 20px;
  }
}
</style>