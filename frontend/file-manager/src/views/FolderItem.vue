<template>
  <div class="folder-item" :class="{ 'selected': isSelected, 'drag-over': dragOver }">
    <div 
      class="folder-header" 
      @click="toggleExpand"
      draggable="true"
      @dragstart="onDragStart"
      @dragover.prevent="onDragOver"
      @dragleave="onDragLeave"
      @drop="onDrop"
    >
      <div class="folder-info">
        <span class="expand-icon" v-if="hasChildren">
          {{ isExpanded ? '−' : '+' }}
        </span>
        <div class="folder-icon-name" @click.stop="selectFolder">
          <svg class="folder-icon" xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M22 19a2 2 0 0 1-2 2H4a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h5l2 3h9a2 2 0 0 1 2 2z"/>
          </svg>
          <span class="folder-name">{{ folder.name }}</span>
        </div>
      </div>
      
      <div class="folder-actions">
         <button class="action-btn" @click.stop="showMoveDialog" title="Mover">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="13 17 18 12 13 7"/>
              <polyline points="6 17 11 12 6 7"/>
            </svg>
          </button>
        <button class="action-btn" @click.stop="deleteFolder" title="Eliminar">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <polyline points="3 6 5 6 21 6"/>
            <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"/>
          </svg>
        </button>
      </div>
    </div>
    
    <div class="subfolders" v-if="isExpanded && hasChildren">
      <FolderItem
        v-for="child in children"
        :key="child.id"
        :folder="child"
        :selected-id="selectedId"
        :all-folders="allFolders"
        @select="$emit('select', $event)"
        @delete="$emit('delete', $event)"
        @move="$emit('move', $event)"
      />
    </div>
  </div>
</template>

<script>
export default {
  name: 'FolderItem',
  props: {
    folder: Object,
    selectedId: Number,
    allFolders: Array
  },
  data() {
    return {
      isExpanded: false,
      dragOver: false
    }
  },
  computed: {
    isSelected() {
      return this.folder.id === this.selectedId
    },
    hasChildren() {
      return this.children.length > 0
    },
    children() {
      return this.allFolders.filter(f => f.parent === this.folder.id)
    }
  },
  methods: {
    toggleExpand() {
      this.isExpanded = !this.isExpanded
    },
    selectFolder() {
      this.$emit('select', this.folder)
    },
    deleteFolder() {
      if (confirm(`¿Eliminar la carpeta "${this.folder.name}" y su contenido?`)) {
        this.$emit('delete', this.folder)
      }
    },
     onDragStart(event) {
      event.dataTransfer.setData('text/plain', this.folder.id)
    },
    onDragOver() {
      this.dragOver = true
    },
    onDragLeave() {
      this.dragOver = false
    },
    onDrop(event) {
      this.dragOver = false
      const draggedFolderId = event.dataTransfer.getData('text/plain')
      
      // Prevenir movimiento a sí mismo
      if (parseInt(draggedFolderId) === this.folder.id) {
        return
      }
      
      // Emitir evento de movimiento
      this.$emit('move', {
        fromId: parseInt(draggedFolderId),
        toParentId: this.folder.id
      })
    },
    showMoveDialog() {
      this.$emit('show-move-dialog', this.folder)
    }
  }
}
</script>

<style scoped>
.folder-item {
  margin-bottom: 5px;
  border-radius: 6px;
  transition: all 0.2s;
}

.folder-item.selected {
  background-color: rgba(1, 118, 211, 0.1);
}

.folder-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 10px;
  cursor: pointer;
  border-radius: 6px;
  transition: all 0.2s;
}

.folder-header:hover {
  background-color: #f0f7ff;
}

.folder-info {
  display: flex;
  align-items: center;
  gap: 8px;
}

.expand-icon {
  width: 20px;
  text-align: center;
  font-weight: bold;
}

.folder-icon-name {
  display: flex;
  align-items: center;
  gap: 8px;
}

.folder-icon {
  color: #0176D3;
}

.folder-name {
  font-weight: 500;
}

.folder-actions {
  display: flex;
  gap: 5px;
  opacity: 0;
  transition: opacity 0.2s;
}

.folder-header:hover .folder-actions {
  opacity: 1;
}

.action-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 5px;
  border-radius: 4px;
  display: flex;
  align-items: center;
  justify-content: center;
}

.action-btn:hover {
  background-color: rgba(0, 0, 0, 0.05);
}

.subfolders {
  margin-left: 28px;
  padding-left: 10px;
  border-left: 2px dashed #e0e0e0;
}
.folder-item.drag-over > .folder-header {
  background-color: #e3f2fd;
  border: 2px dashed #2196f3;
}
</style>