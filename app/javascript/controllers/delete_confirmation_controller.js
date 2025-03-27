import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    confirmMessage: String,
    method: { type: String, default: "delete" }
  }

  connect() {
    console.log("DeleteConfirmationController collegato")
  }

  confirm(event) {
    event.preventDefault()
    
    if (confirm(this.confirmMessageValue)) {
      this.deleteResource()
    }
  }

  deleteResource() {
    const csrfToken = document.querySelector("meta[name='csrf-token']")?.getAttribute("content")
    
    const form = document.createElement("form")
    form.method = "post"
    form.action = this.element.getAttribute("href")
    form.style.display = "none"
    
    const methodInput = document.createElement("input")
    methodInput.type = "hidden"
    methodInput.name = "_method"
    methodInput.value = this.methodValue
    form.appendChild(methodInput)
    
    if (csrfToken) {
      const csrfInput = document.createElement("input")
      csrfInput.type = "hidden"
      csrfInput.name = "authenticity_token"
      csrfInput.value = csrfToken
      form.appendChild(csrfInput)
    }
    
    document.body.appendChild(form)
    form.submit()
  }
}