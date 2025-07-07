<template>
  <form @submit.prevent="$emit('upload-file')" class="upload-form mt-8 flex space-x-4 bg-white p-4 rounded-lg">
    <input
      type="file"
      ref="fileInput"
      @change="$emit('file-change', $event)"
      class="flex-1 block w-full text-gray-700 bg-gray-100 border border-gray-300 rounded-lg cursor-pointer p-3"
    />
    <input
      type="text"
      v-model="fileName"
      placeholder="Nombre del archivo (opcional)"
      class="flex-1 p-3 bg-gray-100 border border-gray-300 rounded-lg text-gray-700 placeholder-gray-500 focus:outline-none focus:ring-2 focus:ring-blue-500"
    />
    <button
      type="submit"
      :disabled="uploading"
      class="px-6 py-3 bg-blue-600 text-white font-semibold rounded-lg shadow hover:bg-blue-700 transition disabled:bg-blue-400 disabled:cursor-not-allowed"
    >
      <span v-if="uploading">
        Subiendo...
      </span>
      <span v-else>
        Subir archivo
      </span>
    </button>
  </form>
</template>

<script>
export default {
  props: {
    uploading: Boolean,
    selectedFolderId: Number
  },
  data() {
    return {
      fileName: ''
    }
  }
}
</script>

<style scoped>
.upload-form {
  box-shadow: 0 4px 10px rgba(0, 0, 0, 0.05);
}

.flex-1 {
  flex: 1 1 0%;
}

.block {
  display: block;
}

.w-full {
  width: 100%;
}

.text-gray-700 {
  color: #4a5568;
}

.bg-gray-100 {
  background-color: #f7fafc;
}

.border {
  border-width: 1px;
}

.border-gray-300 {
  border-color: #e2e8f0;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.cursor-pointer {
  cursor: pointer;
}

.p-3 {
  padding: 0.75rem;
}

.placeholder-gray-500::placeholder {
  color: #a0aec0;
}

.focus\:outline-none:focus {
  outline: none;
}

.focus\:ring-2:focus {
  box-shadow: 0 0 0 2px rgba(66, 153, 225, 0.5);
}

.focus\:ring-blue-500:focus {
  box-shadow: 0 0 0 2px rgba(66, 153, 225, 0.5);
}

.px-6 {
  padding-left: 1.5rem;
  padding-right: 1.5rem;
}

.py-3 {
  padding-top: 0.75rem;
  padding-bottom: 0.75rem;
}

.bg-blue-600 {
  background-color: #3182ce;
}

.text-white {
  color: #fff;
}

.font-semibold {
  font-weight: 600;
}

.rounded-lg {
  border-radius: 0.5rem;
}

.shadow {
  box-shadow: 0 1px 3px 0 rgba(0, 0, 0, 0.1), 0 1px 2px 0 rgba(0, 0, 0, 0.06);
}

.hover\:bg-blue-700:hover {
  background-color: #2b6cb0;
}

.transition {
  transition-property: background-color, border-color, color, fill, stroke, opacity, box-shadow, transform;
  transition-duration: 150ms;
  transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
}

.disabled\:bg-blue-400:disabled {
  background-color: #63b3ed;
}

.disabled\:cursor-not-allowed:disabled {
  cursor: not-allowed;
}
</style>