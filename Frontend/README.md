# 📚 Agenda Escolar - Full-Stack

Um sistema completo de agenda escolar digital desenvolvido para facilitar a organização acadêmica de alunos e professores, centralizando tarefas e rotinas.

## 🚀 Tecnologias Utilizadas

O projeto foi construído utilizando uma arquitetura moderna dividida entre Front-end e Back-end:

*   **Front-end:** Flutter & Dart (Multiplataforma)
*   **Back-end:** Python, FastAPI, Uvicorn
*   **Banco de Dados:** SQLite

## ⚙️ Funcionalidades

*   Dashboard exclusivo e personalizado para Alunos e Professores.
*   Criação e gestão de novas atividades e tarefas.
*   Sistema de cadastro e login de usuários.
*   Interface fluida, responsiva e de fácil navegação.

## 🛠️ Como rodar o projeto localmente

### Pré-requisitos
Certifique-se de ter instalado em sua máquina:
*   [Flutter SDK](https://flutter.dev/docs/get-started/install)
*   [Python 3.x](https://www.python.org/downloads/)

### 1. Iniciando o Back-end (API)
Navegue até a pasta do backend e inicie o servidor:
```bash
cd Backend
# Ative o ambiente virtual (Windows)
.\.venv\Scripts\activate
# Inicie a API
uvicorn main:app --reload
