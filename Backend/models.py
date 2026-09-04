from sqlalchemy import Column, Integer, String, Boolean
from database import Base

class Atividade(Base):
    __tablename__ = "atividades"

    id = Column(Integer, primary_key=True, index=True)
    titulo = Column(String, index=True)
    tipo = Column(String) 
    data = Column(String)
    descricao = Column(String, nullable=True)
    concluida = Column(Boolean, default=False)

class Usuario(Base):
    __tablename__ = "usuarios"

    id = Column(Integer, primary_key=True, index=True)
    nome = Column(String)
    email = Column(String, unique=True, index=True)
    senha = Column(String)
    perfil = Column(String) # 'Professor' ou 'Aluno'