import axios from 'axios'

const api = axios.create({
  baseURL: '/api/', // gracias al proxy de Vite
})

export default api