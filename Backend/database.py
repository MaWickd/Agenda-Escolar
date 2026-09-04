from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

# Cria o arquivo do banco de dados na mesma pasta
SQLALCHEMY_DATABASE_URL = "sqlite:///./agenda.db"

# connect_args é necessário para o SQLite trabalhar bem com o FastAPI
engine = create_engine(SQLALCHEMY_DATABASE_URL, connect_args={"check_same_thread": False})
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()