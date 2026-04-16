import requests
import typer

BASE = "http://host.docker.internal:41184"
TOKEN_PATH = "/run/secrets/joplin_api_token"

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


if __name__ == "__main__":
    app()