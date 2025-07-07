<template>
  <div class="modal-overlay" @click.self="$emit('close')">
    <div class="modal-content">
      <div class="modal-header">
        <h3>Mover {{ itemType }}: {{ currentItemName }}</h3>
        <button class="btn-close" @click="$emit('close')">
          <i class="fas fa-times"></i>
        </button>
      </div>
      
      <div class="modal-body">
        <p>Selecciona la nueva ubicación:</p>
        
        <div class="folder-options">
          <div 
            class="folder-option"
            :class="{ 'selected': selectedFolder === null }"
            @click="selectFolder(null)"
          >
            <i class="fas fa-home"></i>
            <div class="folder-path">
              <span class="folder-name">Carpeta Raíz</span>
              <span class="folder-location">/</span>
            </div>
          </div>
          
          <div 
            v-for="folder in availableFolders" 
            :key="folder.id"
            class="folder-option"
            :class="{ 'selected': selectedFolder === folder.id }"
            @click="selectFolder(folder.id)"
          >
            <i class="fas fa-folder"></i>
            <div class="folder-path">
              <span class="folder-name">{{ folder.name }}</span>
              <span class="folder-location">{{ getFolderPath(folder) }}</span>
            </div>
          </div>
        </div>
      </div>
      
      <div class="modal-footer">
        <button class="btn btn-cancel" @click="$emit('close')">
          Cancelar
        </button>
        <button 
          class="btn btn-confirm" 
          @click="confirmMove"
          :disabled="!selectedFolder && selectedFolder !== null"
        >
          Mover aquí
        </button>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  props: {
    currentItem: Object,
    folders: Array
  },
  data() {
    return {
      selectedFolder: null
    }
  },
  computed: {
    itemType() {
      return this.currentItem?.type === 'folder' ? 'carpeta' : 'archivo'
    },
    currentItemName() {
      return this.currentItem?.name || ''
    },
    availableFolders() {
      return this.folders.filter(folder => {
        return folder.id !== this.currentItem?.id && 
               !this.isDescendant(this.currentItem?.id, folder.id)
      })
    }
  },
  methods: {
    selectFolder(folderId) {
      this.selectedFolder = folderId
    },
    confirmMove() {
      this.$emit('move', this.selectedFolder)
    },
    getFolderPath(folder) {
      let path = []
      let current = folder
      
      while (current.parent !== null) {
        const parent = this.folders.find(f => f.id === current.parent)
        if (parent) {
          path.unshift(parent.name)
          current = parent
        } else {
          break
        }
      }
      
      return path.length > 0 ? `/${path.join('/')}` : ''
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
    }
  }
}
</script>

<style scoped>
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background-color: rgba(0, 0, 0, 0.5);
  display: flex;
  justify-content: center;
  align-items: center;
  z-index: 1000;
}

.modal-content {
  background-color: white;
  border-radius: 8px;
  width: 500px;
  max-width: 90%;
  max-height: 80vh;
  display: flex;
  flex-direction: column;
}

.modal-header {
  padding: 15px 20px;
  border-bottom: 1px solid #eee;
  display: flex;
  justify-content: space-between;
  align-items: center;
}

.modal-header h3 {
  margin: 0;
  font-size: 18px;
  color: #333;
}

.btn-close {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #777;
}

.modal-body {
  padding: 20px;
  flex-grow: 1;
  overflow-y: auto;
}

.folder-options {
  margin-top: 15px;
}

.folder-option {
  padding: 12px 15px;
  margin-bottom: 8px;
  border-radius: 6px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 10px;
  transition: background-color 0.2s;
}

.folder-option:hover {
  background-color: #f5f5f5;
}

.folder-option.selected {
  background-color: #E3F2FD;
  font-weight: 500;
}

.folder-option i {
  font-size: 18px;
  color: #FFA000;
  flex-shrink: 0;
}

.folder-option.selected i {
  color: #1976D2;
}

.folder-path {
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.folder-name {
  font-weight: 500;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.folder-location {
  font-size: 12px;
  color: #757575;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.modal-footer {
  padding: 15px 20px;
  border-top: 1px solid #eee;
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}

.btn {
  padding: 8px 16px;
  border-radius: 4px;
  font-weight: 500;
  cursor: pointer;
}

.btn-cancel {
  background-color: white;
  border: 1px solid #ddd;
}

.btn-confirm {
  background-color: #2196F3;
  color: white;
  border: none;
}

.btn-confirm:disabled {
  background-color: #BBDEFB;
  cursor: not-allowed;
}
</style>