# 🎮 GamesApp - Gerenciador de Coleção de Jogos (iOS)

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://developer.apple.com/swift/)
[![iOS](https://img.shields.io/badge/iOS-16%2B-blue.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-Latest-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![Firebase](https://img.shields.io/badge/Firebase-Latest-orange.svg)](https://firebase.google.com)

Aplicativo **iOS** em **SwiftUI** para gerenciar coleção pessoal de jogos, com integração a **Firebase** (Auth, Firestore, Storage) e fallback local para funcionar offline.

## 📋 Índice

- [Sobre o Projeto](#sobre-o-projeto)
- [Funcionalidades](#funcionalidades)
- [Tecnologias Utilizadas](#tecnologias-utilizadas)
- [Arquitetura](#arquitetura)
- [Firebase](#firebase)
- [Pré-requisitos](#pré-requisitos)
- [Instalação e Execução](#instalação-e-execução)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Autor](#autor)

## 🎯 Sobre o Projeto

O **GamesApp iOS** permite criar, listar, editar e excluir jogos com capa, status, nota e notas pessoais. Oferece login/registro, troca de email, troca de senha, recuperação por email e exclusão de conta. Se o Firebase não estiver disponível, usa armazenamento local (Application Support) para dados e capas.

## ✨ Funcionalidades

### 🔐 Autenticação e Conta

- Login/Registro via Firebase Auth
- Recuperação de senha por email
- Troca de email (re-autenticação)
- Troca de senha com requisitos visíveis
- Exclusão de conta + limpeza de dados
- Logout

### 🎮 Jogos

- CRUD completo com formulário e capa (galeria)
- Lista com busca, filtros e ordenação
- Seleção em massa e exclusão múltipla
- Status (Backlog/Jogando/Concluído), nota (0-5), notas pessoais

### 📷 Capas

- Upload para Firebase Storage ou armazenamento local
- Preview assíncrona (AsyncImage) para URLs remotas
- Remoção de capa antiga ao atualizar

### 🧭 UX

- Telas separadas para login/registro/recuperar senha
- Telas dedicadas para alterar email/senha e excluir conta
- Loading explícito ao salvar novos jogos
- Botão “Selecionar tudo/Limpar seleção” no modo de edição da lista

## 🛠️ Tecnologias Utilizadas

- **Swift 5.9** + **SwiftUI**
- **Firebase**: Auth, Firestore, Storage
- **os.Logger** para logs (DEBUG mostra info; RELEASE suprime debug)
- **PhotosUI** para escolha de imagens

## 🏗️ Arquitetura

Padrão **MVVM** com separação por feature:

```
View (SwiftUI) -> ViewModel -> Services (Firebase/Local) -> Models
```

- **Views**: telas de Auth, Lista, Formulário, Perfil, componentes compartilhados.
- **ViewModels**: `SessionViewModel`, `GameListViewModel`.
- **Services**: `AuthService`, `GameRepository`, `ImageStore` com implementações Firebase e fallback local.
- **Models**: `Game`, `GameDraft`, `GameStatus`, `SortKey`, `UserProfile`, `AppError`.

## 🔥 Firebase

1. **Adicionar app iOS no Firebase Console**
   - Bundle ID: `Levi.GamesappCollectionManager` (ou o seu, mas mantenha o mesmo em Xcode e Firebase).
   - Baixe `GoogleService-Info.plist` e coloque na raiz do projeto (já está no .gitignore para evitar vazamento).
2. **Pacotes SPM** (já referenciados no projeto):
   - `FirebaseAuth`, `FirebaseFirestore`, `FirebaseStorage` (via `firebase-ios-sdk`).
   - Garanta que estão marcados no target `GamesappCollectionManager` em “Frameworks, Libraries, and Embedded Content”.
3. **Regras** (exemplo seguro):
   - Firestore: restringir `users/{userId}/games/{gameId}` ao `request.auth.uid == userId`.
   - Storage: restringir `users/{userId}/covers/**` ao mesmo usuário.
4. **Configuração no código**:
   - `FirebaseApp.configure()` já chamado em `GamesappCollectionManagerApp`.
   - Logs de integração usam `os.Logger` (categoria `auth/games/images`).

## 📦 Pré-requisitos

- macOS com **Xcode 15+**
- iOS **16+** (alvo)
- Conta no **Firebase** e pacotes adicionados via Swift Package Manager

## 🚀 Instalação e Execução

1. Clone o repositório:
   ```bash
   git clone https://github.com/LeviLunique/gamesapp-collection-manager-ios.git
   cd gamesapp-collection-manager-ios
   ```
2. Abra no Xcode:
   - File > Open e selecione `GamesappCollectionManager.xcodeproj`.
   - File > Packages > Resolve Package Versions (se necessário).
3. Firebase:
   - Adicione `GoogleService-Info.plist` na raiz do projeto (inclua no target).
4. Executar:
   - Escolha simulador ou device.
   - ⌘+R para rodar.

## 📁 Estrutura do Projeto

```
GamesappCollectionManager/
├── App/                          # App entry
├── Assets.xcassets               # Assets
├── Models/                       # Modelos (Game, User, erros, enums)
├── Services/
│   ├── Firebase/                 # Auth/Game/Images (Firebase)
│   ├── Local/                    # Fallback local (JSON + files)
│   ├── Logging.swift             # os.Logger categories
│   ├── Protocols.swift           # Contratos de serviço
│   └── ServiceFactory.swift      # Injeta Firebase ou Local
├── Support/                      # Utilidades
├── ViewModels/                   # SessionViewModel, GameListViewModel
└── Views/
    ├── App/                      # AppRoot, ContentView
    ├── Auth/                     # Login, Registro, Esqueci Senha
    ├── Games/                    # Lista, Form, Row
    ├── Main/                     # Tab bar
    ├── Profile/                  # Perfil, alterar email/senha, excluir conta
    └── Shared/                   # Campos e componentes reutilizáveis
```

## 👨‍💻 Autor

**Levi Lunique Izidio da Silva**

- GitHub: [@LeviLunique](https://github.com/LeviLunique/)
- Email: levi.lunique@gmail.com
- LinkedIn: [Levi Lunique](https://linkedin.com/in/levi-lunique)

---

**Desenvolvido com ❤️ e ☕**
