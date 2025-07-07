import os
import requests
from fpdf import FPDF

API_KEY    = "jncTi1Q5XL7D8mHISrclz4OOnX9TXnM129W5rXHp"
EXTRACT_URL = "https://pro.api.runpulse.com/extract_beta"

def txt_to_pdf(txt_path, pdf_path):
    pdf = FPDF()
    pdf.set_auto_page_break(auto=True, margin=15)
    pdf.add_page()
    pdf.set_font("Arial", size=12)
    with open(txt_path, 'r', encoding='utf-8') as file:
        for line in file:
            pdf.multi_cell(0, 10, line.strip())
    pdf.output(pdf_path)

def extract_metadata(file_path):
    # Si es .txt, convierto a PDF
    if not file_path.lower().endswith(".pdf"):
        pdf_path = file_path.rsplit('.', 1)[0] + ".pdf"
        txt_to_pdf(file_path, pdf_path)
        print(f"📄 Convertido a PDF: {pdf_path}")
        file_path = pdf_path

    print(f"📤 Enviando {os.path.basename(file_path)} a /extract_beta")

    headers = {"x-api-key": API_KEY}
    data = {
        "chunking": "semantic,recursive",
        "return_table": True,
        "experimental_return_table": True,
        "schema": "{}",
        "schema_prompt": "",
        "pages": ""
    }

    with open(file_path, "rb") as f:
        files = {"file": (os.path.basename(file_path), f)}
        response = requests.post(EXTRACT_URL, headers=headers, files=files, data=data)

    print(f"📥 Código HTTP: {response.status_code}")
    print("📥 Headers de respuesta:")
    for k, v in response.headers.items():
        print(f"   {k}: {v}")
    print("📥 Body (raw):")
    print(response.text)    # impresión cruda

    # Intentamos parsear JSON
    try:
        payload = response.json()
    except Exception as e:
        print("❌ Error parseando JSON:", e)
        return {}

    # Mostrar JSON formateado
    import json
    print("📥 Body (JSON formateado):")
    print(json.dumps(payload, indent=2, ensure_ascii=False))

    if response.status_code != 200:
        print("❌ Pulse devolvió error, no extraigo metadata.")
        return {}

    # Extraemos los campos de interés
    language   = payload.get("plan-info", {}).get("language")
    entities   = payload.get("schema-json", {}).get("entities")
    line_count = payload.get("plan-info", {}).get("pages_used")

    print("📊 Campos extraídos:")
    print(f"   language: {language!r}")
    print(f"   entities: {entities!r}")
    print(f"   line_count: {line_count!r}")

    return {
        "language": language,
        "entities": entities,
        "line_count": line_count,
        "raw": payload
    }