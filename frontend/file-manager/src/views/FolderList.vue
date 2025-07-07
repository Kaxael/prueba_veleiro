<template>
  <div class="folder-list">
    <div 
      v-for="folder in folders" 
      :key="folder.id"
      class="folder-item"
    >
      <div class="folder-info" @click="$emit('select', folder)">
        <i class="fas fa-folder"></i>
        <span>{{ folder.name }}</span>
      </div>
      <div class="folder-actions">
    <button class="btn-move" @click.stop="$emit('move', { id: folder.id, type: 'folder' })" title="Mover carpeta">
      <i class="fas fa-arrows-alt"></i>
      <span class="btn-text">Mover</span>
    </button>
    <button class="btn-delete" @click.stop="$emit('delete', folder)" title="Eliminar carpeta">
      <i class="fas fa-trash-alt"></i>
      <span class="btn-text">Eliminar</span>
    </button>
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
    }
  }
}
</script>

<style scoped>
.folder-list {
  border: 1px solid #eee;
  border-radius: 6px;
  overflow: hidden;
}

.folder-item {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 12px 15px;
  border-bottom: 1px solid #eee;
  transition: background-color 0.2s;
}

.folder-item:last-child {
  border-bottom: none;
}

.folder-item:hover {
  background-color: #f5f5f5;
}

.folder-info {
  display: flex;
  align-items: center;
  flex: 1;
  cursor: pointer;
}

.folder-info i {
  color: #FFA000;
  margin-right: 10px;
  font-size: 18px;
}

.folder-actions {
  display: flex;
  gap: 8px;
}

.btn-move, .btn-delete {
  padding: 6px 10px;
  border-radius: 4px;
  font-size: 13px;
  border: none;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 5px;
}
.btn-move {
  background-color: #E3F2FD;
  color: #1976D2;
}

.btn-move:hover {
  background-color: #BBDEFB;
}

.btn-delete {
  background-color: #FFEBEE;
  color: #D32F2F;
}

.btn-delete:hover {
  background-color: #FFCDD2;
}

@media (max-width: 768px) {
  .btn-move, .btn-delete {
    padding: 6px 8px;
    min-width: auto;
  }
  
  .btn-text {
    display: none;
  }
}

</style>