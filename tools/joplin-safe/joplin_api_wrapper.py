import requests
import typer
import json

from pathlib import Path

BASE = "http://host.docker.internal:41184"
BASE = "http://localhost:41184"  # For local testing

TOKEN_PATH = "/run/secrets/joplin_api_token"
TOKEN_PATH = "./secrets/joplin_api_token"  # For local testing

with open(TOKEN_PATH, "r") as f:
    TOKEN = f.read().strip()   

ALLOWED_NOTEBOOK = "4. OpenClaw"

app = typer.Typer()

def _get_notebook_id() -> str:
    response = requests.get(
        f"{BASE}/folders",
        params={"token": TOKEN},
        timeout=30,
    )
    response.raise_for_status()

    data = response.json()
    for notebook in data.get("items", []):
        if notebook.get("title") == ALLOWED_NOTEBOOK:
            return notebook["id"]

    raise typer.Exit(
        code=1,
    )


@app.command()
def get_notebook_id() -> None:
    """Print the allowed notebook id."""
    notebook_id = _get_notebook_id()
    typer.echo(notebook_id)


@app.command()
def create_note(title: str, body: str) -> None:
    """Create a note inside the allowed notebook."""
    notebook_id = _get_notebook_id()
    response = requests.post(
        f"{BASE}/notes",
        params={"token": TOKEN},
        json={
            "title": title,
            "body": body,
            "parent_id": notebook_id,
        },
        timeout=30,
    )
    response.raise_for_status()
    typer.echo(response.text)


@app.command()
def list_notes() -> None:
    """List notes from the allowed notebook."""
    notebook_id = _get_notebook_id()
    response = requests.get(
        f"{BASE}/folders/{notebook_id}/notes",
        params={"token": TOKEN},
        timeout=30,
    )
    response.raise_for_status()
    typer.echo(response.text)

@app.command()
def upload_file(file_path: str, title: str = None) -> None:
    """Upload a file as a resource and create a note for it."""
    path = Path(file_path)
    if not path.exists():
        typer.echo(f"Error: File {file_path} not found.")
        raise typer.Exit(code=1)

    # 1. Upload the File as a Resource
    # The Joplin API requires the metadata (props) to be sent as a string 
    # alongside the file data in a multipart request.
    props = json.dumps({
        "title": title or path.name,
        "filename": path.name
    })

    with open(path, "rb") as f:
        files = {
            "data": (path.name, f),
            "props": (None, props),
        }
        response = requests.post(
            f"{BASE}/resources",
            params={"token": TOKEN},
            files=files,
            timeout=60  # Increased timeout for large files
        )
    
    response.raise_for_status()
    resource_id = response.json().get("id")

    # 2. Create the Note linking to the resource
    notebook_id = _get_notebook_id()
    note_body = f"File uploaded from OpenClaw:\n\n[{path.name}](:/{resource_id})"
    
    note_response = requests.post(
        f"{BASE}/notes",
        params={"token": TOKEN},
        json={
            "title": f"📎 {title or path.name}",
            "body": note_body,
            "parent_id": notebook_id,
        },
        timeout=30,
    )
    note_response.raise_for_status()
    
    typer.echo(f"Successfully uploaded {path.name} (ID: {resource_id}) to Joplin") 

if __name__ == "__main__":
    app()