<template>
  <div class="folder-content">
    <!-- Subcarpetas -->
    <div class="section">
      <h3><i class="fas fa-folder-open"></i> Subcarpetas</h3>
      <div class="items-list" v-if="folders.length > 0">
        <div 
          v-for="folder in folders" 
          :key="folder.id"
          class="item"
        >
          <div class="item-info" @click="$emit('select-folder', folder)">
            <i class="fas fa-folder"></i>
            <span>{{ folder.name }}</span>
          </div>
          
          <!-- Botones de Acción -->
          <div class="item-actions">
            <button 
              class="btn-action btn-move" 
              @click.stop="$emit('move', { id: folder.id, type: 'folder' })"
              title="Mover carpeta"
            >
              <i class="fas fa-arrows-alt"></i>
              <span class="btn-text">Mover</span>
            </button>
            <button 
              class="btn-action btn-delete" 
              @click.stop="confirmDeleteFolder(folder)"
              title="Eliminar carpeta"
            >
              <i class="fas fa-trash-alt"></i>
              <span class="btn-text">Eliminar</span>
            </button>
          </div>
        </div>
      </div>
      <div v-else class="no-items">
        No hay subcarpetas
      </div>
    </div>

    <!-- Archivos -->
    <div class="section">
      <h3><i class="fas fa-file-alt"></i> Archivos</h3>
      <div class="items-list" v-if="files.length > 0">
        <div 
          v-for="file in files" 
          :key="file.id"
          class="item"
        >
          <div class="item-info" @click="toggleFileDetails(file)">
            <i :class="getFileIcon(file)"></i>
            <span>{{ file.name }}</span>
          </div>
          <div class="item-actions">
            <button 
              class="btn-action btn-view" 
              @click.stop="toggleFileDetails(file)"
              :class="{ active: showDetails && selectedFile?.id === file.id }"
              title="Ver detalles"
            >
              <i class="fas fa-info-circle"></i>
              <span class="btn-text">Detalle</span>
            </button>
            <button 
              class="btn-action btn-move" 
              @click.stop="$emit('move', { id: file.id, type: 'file' })"
              title="Mover archivo"
            >
              <i class="fas fa-arrows-alt"></i>
              <span class="btn-text">Mover</span>
            </button>
            <button 
              class="btn-action btn-delete" 
              @click.stop="confirmDeleteFile(file)"
              title="Eliminar archivo"
            >
              <i class="fas fa-trash-alt"></i>
              <span class="btn-text">Eliminar</span>
            </button>
          </div>
        </div>
      </div>
      <div v-else class="no-items">
        No hay archivos
      </div>

      <!-- Panel de detalles -->
      <div v-if="showDetails && selectedFile" class="file-details-panel">
        <div class="panel-header">
          <h4>Detalles del Archivo</h4>
          <button class="btn-close" @click="closeDetails">
            <i class="fas fa-times"></i>
          </button>
        </div>
        <div class="panel-content">
          <div class="metadata-grid">
            <div class="metadata-item">
              <span class="metadata-label">Nombre:</span>
              <span class="metadata-value">{{ selectedFile.name }}</span>
            </div>
            <div class="metadata-item">
              <span class="metadata-label">Tipo:</span>
              <span class="metadata-value">{{ getFileType(selectedFile.name) }}</span>
            </div>
            <div class="metadata-item">
              <span class="metadata-label">Tamaño:</span>
              <span class="metadata-value">{{ getFileSize(selectedFile.file) }}</span>
            </div>
            <div class="metadata-item">
              <span class="metadata-label">Subido:</span>
              <span class="metadata-value">{{ formatDate(selectedFile.uploaded_at) }}</span>
            </div>
            
            <template v-if="selectedFile.metadata">
              <div class="metadata-item" v-if="selectedFile.metadata.line_count">
                <span class="metadata-label">Líneas:</span>
                <span class="metadata-value">{{ selectedFile.metadata.line_count }}</span>
              </div>
              <div class="metadata-item" v-if="selectedFile.metadata.language">
                <span class="metadata-label">Idioma:</span>
                <span class="metadata-value">{{ selectedFile.metadata.language }}</span>
              </div>
              <div class="metadata-item" v-if="selectedFile.metadata.named_entities">
                <span class="metadata-label">Entidades:</span>
                <span class="metadata-value">{{ selectedFile.metadata.named_entities.join(', ') }}</span>
              </div>
            </template>
          </div>
          
          <a :href="selectedFile.file" target="_blank" class="btn-download">
            <i class="fas fa-download"></i> Descargar Archivo
          </a>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    folders: {
      type: Array,
      default: () => []
    },
    files: {
      type: Array,
      default: () => []
    }
  },
  data() {
    return {
      selectedFile: null,
      showDetails: false
    }
  },
  methods: {
    getFileIcon(file) {
      const extension = file.name.split('.').pop().toLowerCase()
      const icons = {
        txt: 'fas fa-file-alt',
        csv: 'fas fa-file-csv',
        pdf: 'fas fa-file-pdf',
        doc: 'fas fa-file-word',
        docx: 'fas fa-file-word',
        xls: 'fas fa-file-excel',
        xlsx: 'fas fa-file-excel',
        jpg: 'fas fa-file-image',
        png: 'fas fa-file-image'
      }
      return icons[extension] || 'fas fa-file'
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
        month: 'short', 
        day: 'numeric',
        hour: '2-digit',
        minute: '2-digit'
      }
      return new Date(dateString).toLocaleDateString('es-ES', options)
    },
    confirmDeleteFolder(folder) {
      if (confirm(`¿Eliminar la carpeta "${folder.name}" y todo su contenido?`)) {
        this.$emit('delete-folder', folder)
      }
    },
    confirmDeleteFile(file) {
      if (confirm(`¿Eliminar el archivo "${file.name}" permanentemente?`)) {
        this.$emit('delete-file', file)
      }
    },
    toggleFileDetails(file) {
      if (this.showDetails && this.selectedFile?.id === file.id) {
        this.closeDetails()
        return
      }
      
      this.selectedFile = file
      this.showDetails = true
      
      this.$nextTick(() => {
        const panel = this.$el.querySelector('.file-details-panel')
        if (panel) {
          panel.scrollIntoView({ behavior: 'smooth', block: 'nearest' })
        }
      })
    },
    closeDetails() {
      this.showDetails = false
      this.selectedFile = null
    },
    getFileSize(fileUrl) {
      return 'N/A'
    }
  }
}
</script>

<style scoped>
.folder-content {
  margin-top: 20px;
}

.section {
  margin-bottom: 30px;
}

.section h3 {
  color: #555;
  font-size: 18px;
  margin-bottom: 15px;
  display: flex;
  align-items: center;
  gap: 10px;
  padding-bottom: 8px;
  border-bottom: 1px solid #eee;
}

.items-list {
  border: 1px solid #e0e0e0;
  border-radius: 8px;
  overflow: hidden;
}

.item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 15px;
  border-bottom: 1px solid #f0f0f0;
  transition: background-color 0.2s;
}

.item:last-child {
  border-bottom: none;
}

.item:hover {
  background-color: #f8f8f8;
}

.item-info {
  display: flex;
  align-items: center;
  flex: 1;
  cursor: pointer;
  min-width: 0;
}

.item-info i {
  margin-right: 12px;
  font-size: 20px;
  flex-shrink: 0;
}

.fa-folder {
  color: #FFA000;
}

.item-info span {
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.item-actions {
  display: flex;
  gap: 8px;
  margin-left: 15px;
  flex-shrink: 0;
}

.btn-action {
  padding: 8px 12px;
  border-radius: 4px;
  font-size: 14px;
  cursor: pointer;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 6px;
  transition: all 0.2s;
  border: 1px solid transparent;
  min-width: 40px;
}


.btn-move {
  background-color: #e3f2fd;
  color: #1976d2;
  border-color: #bbdefb;
}

.btn-move:hover {
  background-color: #bbdefb;
}

.btn-delete {
  background-color: #ffebee;
  color: #d32f2f;
  border-color: #ffcdd2;
}

.btn-delete:hover {
  background-color: #ffcdd2;
}

.btn-view {
  color: #2196F3;
  background-color: transparent;
}

.btn-view:hover, .btn-view.active {
  background-color: #E3F2FD;
}

.no-items {
  padding: 15px;
  text-align: center;
  color: #757575;
  font-style: italic;
  background-color: #fafafa;
  border-radius: 8px;
  border: 1px dashed #e0e0e0;
}

.file-details-panel {
  margin-top: 20px;
  border: 1px solid #eee;
  border-radius: 8px;
  padding: 20px;
  background: #f9f9f9;
  animation: fadeIn 0.3s ease;
}

@keyframes fadeIn {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

.panel-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 20px;
}

.panel-header h4 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.btn-close {
  background: none;
  border: none;
  color: #777;
  cursor: pointer;
  font-size: 16px;
}

.metadata-grid {
  display: grid;
  grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
  gap: 15px;
  margin-bottom: 20px;
}

.metadata-item {
  display: flex;
  flex-direction: column;
}

.metadata-label {
  font-size: 13px;
  color: #666;
  margin-bottom: 2px;
}

.metadata-value {
  font-size: 14px;
  color: #333;
  word-break: break-word;
}

.btn-download {
  display: inline-flex;
  align-items: center;
  padding: 8px 15px;
  background-color: #4CAF50;
  color: white;
  border-radius: 4px;
  text-decoration: none;
  font-size: 14px;
  margin-top: 10px;
}

.btn-download:hover {
  background-color: #388E3C;
}

.btn-download i {
  margin-right: 8px;
}



</style>