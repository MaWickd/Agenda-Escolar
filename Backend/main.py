from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List
import models, schemas
from database import SessionLocal, engine

# Cria as tabelas no banco de dados automaticamente
models.Base.metadata.create_all(bind=engine)

# Injeta o professor padrão caso o banco esteja vazio
db_setup = SessionLocal()
admin_existe = db_setup.query(models.Usuario).filter(models.Usuario.email == "admin@escola.com").first()
if not admin_existe:
    novo_admin = models.Usuario(nome="Professor Admin", email="admin@escola.com", senha="123", perfil="Professor")
    db_setup.add(novo_admin)
    db_setup.commit()
db_setup.close()

app = FastAPI(title="API Agenda Escolar")

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

# --- ROTAS DE USUÁRIOS E LOGIN ---

@app.post("/login/")
def fazer_login(dados: schemas.UsuarioLogin, db: Session = Depends(get_db)):
    usuario = db.query(models.Usuario).filter(
        models.Usuario.email == dados.email, 
        models.Usuario.senha == dados.senha,
        models.Usuario.perfil == dados.perfil
    ).first()
    
    if not usuario:
        raise HTTPException(status_code=401, detail="E-mail, senha ou perfil incorretos")
    return {"id": usuario.id, "nome": usuario.nome, "perfil": usuario.perfil}

@app.post("/usuarios/", response_model=schemas.UsuarioResponse)
def criar_usuario(usuario: schemas.UsuarioCreate, db: Session = Depends(get_db)):
    email_existe = db.query(models.Usuario).filter(models.Usuario.email == usuario.email).first()
    if email_existe:
        raise HTTPException(status_code=400, detail="E-mail já cadastrado")
    
    db_usuario = models.Usuario(**usuario.model_dump())
    db.add(db_usuario)
    db.commit()
    db.refresh(db_usuario)
    return db_usuario

# --- ROTAS DE ATIVIDADES (CRUD) ---

@app.post("/atividades/", response_model=schemas.AtividadeResponse)
def criar_atividade(atividade: schemas.AtividadeCreate, db: Session = Depends(get_db)):
    db_atividade = models.Atividade(**atividade.model_dump())
    db.add(db_atividade)
    db.commit()
    db.refresh(db_atividade)
    return db_atividade

@app.get("/atividades/", response_model=List[schemas.AtividadeResponse])
def listar_atividades(db: Session = Depends(get_db)):
    return db.query(models.Atividade).all()

@app.put("/atividades/{atividade_id}", response_model=schemas.AtividadeResponse)
def atualizar_atividade(atividade_id: int, atividade: schemas.AtividadeCreate, db: Session = Depends(get_db)):
    db_atividade = db.query(models.Atividade).filter(models.Atividade.id == atividade_id).first()
    if not db_atividade:
        raise HTTPException(status_code=404, detail="Atividade não encontrada")
    
    for key, value in atividade.model_dump().items():
        setattr(db_atividade, key, value)
        
    db.commit()
    db.refresh(db_atividade)
    return db_atividade

@app.delete("/atividades/{atividade_id}")
def deletar_atividade(atividade_id: int, db: Session = Depends(get_db)):
    db_atividade = db.query(models.Atividade).filter(models.Atividade.id == atividade_id).first()
    if not db_atividade:
        raise HTTPException(status_code=404, detail="Atividade não encontrada")
    db.delete(db_atividade)
    db.commit()
    return {"mensagem": "Deletado com sucesso"}
# Rota para LISTAR todos os usuários (GET) - Útil para ver os IDs no Swagger
@app.get("/usuarios/", response_model=List[schemas.UsuarioResponse])
def listar_usuarios(db: Session = Depends(get_db)):
    return db.query(models.Usuario).all()

# Rota para DELETAR um usuário pelo ID (DELETE)
@app.delete("/usuarios/{usuario_id}")
def deletar_usuario(usuario_id: int, db: Session = Depends(get_db)):
    db_usuario = db.query(models.Usuario).filter(models.Usuario.id == usuario_id).first()
    if not db_usuario:
        raise HTTPException(status_code=404, detail="Usuário não encontrado")
    
    # Proteção para não apagar o admin principal sem querer
    if db_usuario.email == "admin@escola.com":
        raise HTTPException(status_code=400, detail="Não é permitido deletar o administrador principal")
    
    db.delete(db_usuario)
    db.commit()
    return {"mensagem": "Usuário deletado com sucesso"}