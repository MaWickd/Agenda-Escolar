from pydantic import BaseModel
from typing import Optional

class AtividadeBase(BaseModel):
    titulo: str
    tipo: str
    data: str
    descricao: Optional[str] = "Nenhuma descrição informada."
    concluida: bool = False

# Usado na hora de criar (POST)
class AtividadeCreate(AtividadeBase):
    pass

# Usado na hora de enviar para o Flutter (GET)
class AtividadeResponse(AtividadeBase):
    id: int

    class Config:
        from_attributes = True

# --- SCHEMAS DE USUÁRIOS ---

class UsuarioLogin(BaseModel):
    email: str
    senha: str
    perfil: str

class UsuarioCreate(BaseModel):
    nome: str
    email: str
    senha: str
    perfil: str

class UsuarioResponse(BaseModel):
    id: int
    nome: str
    email: str
    perfil: str

    class Config:
        from_attributes = True