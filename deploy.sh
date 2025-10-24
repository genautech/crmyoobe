#!/bin/bash

# 🚀 Script de Deploy Automático - Yoobe CRM
# Suporta: Firebase, Vercel, Netlify, GitHub Pages

set -e

echo "🚀 Deploy Automático - Yoobe CRM"
echo "=================================="
echo ""

# Cores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Função para printar com cor
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Verificar se está no diretório correto
if [ ! -f "pubspec.yaml" ]; then
    print_error "Execute este script na raiz do projeto Flutter!"
    exit 1
fi

# Menu de opções
echo "Escolha a plataforma de deploy:"
echo ""
echo "1) 🔥 Firebase Hosting (recomendado)"
echo "2) ⚡ Vercel"
echo "3) 🟢 Netlify"
echo "4) 📘 GitHub Pages"
echo "5) 🔨 Build apenas (sem deploy)"
echo ""
read -p "Digite o número da opção: " option

case $option in
    1)
        PLATFORM="firebase"
        ;;
    2)
        PLATFORM="vercel"
        ;;
    3)
        PLATFORM="netlify"
        ;;
    4)
        PLATFORM="github"
        ;;
    5)
        PLATFORM="build-only"
        ;;
    *)
        print_error "Opção inválida!"
        exit 1
        ;;
esac

echo ""
print_info "Plataforma selecionada: $PLATFORM"
echo ""

# Step 1: Flutter build
print_info "🔨 Compilando aplicação Flutter..."
flutter build web --release

if [ $? -eq 0 ]; then
    print_success "Build concluído com sucesso!"
else
    print_error "Falha no build!"
    exit 1
fi

# Step 2: Deploy conforme plataforma
case $PLATFORM in
    firebase)
        print_info "🔥 Iniciando deploy no Firebase Hosting..."
        
        # Verificar se Firebase CLI está instalado
        if ! command -v firebase &> /dev/null; then
            print_warning "Firebase CLI não encontrado!"
            print_info "Instalando Firebase CLI..."
            npm install -g firebase-tools
        fi
        
        # Fazer deploy
        firebase deploy --only hosting
        
        if [ $? -eq 0 ]; then
            print_success "Deploy no Firebase concluído!"
            print_info "URLs disponíveis:"
            echo "  - https://crmyoobe.web.app"
            echo "  - https://crmyoobe.firebaseapp.com"
        else
            print_error "Falha no deploy do Firebase!"
            exit 1
        fi
        ;;
        
    vercel)
        print_info "⚡ Iniciando deploy no Vercel..."
        
        # Verificar se Vercel CLI está instalado
        if ! command -v vercel &> /dev/null; then
            print_warning "Vercel CLI não encontrado!"
            print_info "Instalando Vercel CLI..."
            npm install -g vercel
        fi
        
        # Fazer deploy
        cd build/web
        vercel --prod
        cd ../..
        
        if [ $? -eq 0 ]; then
            print_success "Deploy no Vercel concluído!"
        else
            print_error "Falha no deploy do Vercel!"
            exit 1
        fi
        ;;
        
    netlify)
        print_info "🟢 Iniciando deploy no Netlify..."
        
        # Verificar se Netlify CLI está instalado
        if ! command -v netlify &> /dev/null; then
            print_warning "Netlify CLI não encontrado!"
            print_info "Instalando Netlify CLI..."
            npm install -g netlify-cli
        fi
        
        # Fazer deploy
        netlify deploy --prod --dir=build/web
        
        if [ $? -eq 0 ]; then
            print_success "Deploy no Netlify concluído!"
        else
            print_error "Falha no deploy do Netlify!"
            exit 1
        fi
        ;;
        
    github)
        print_info "📘 Preparando deploy no GitHub Pages..."
        
        # Criar branch gh-pages se não existir
        git checkout -b gh-pages 2>/dev/null || git checkout gh-pages
        
        # Limpar branch
        git rm -rf . 2>/dev/null || true
        
        # Copiar build
        cp -r build/web/* .
        
        # Adicionar arquivo .nojekyll
        touch .nojekyll
        
        # Commit e push
        git add .
        git commit -m "Deploy to GitHub Pages - $(date)"
        git push origin gh-pages --force
        
        # Voltar para branch main
        git checkout main 2>/dev/null || git checkout master
        
        if [ $? -eq 0 ]; then
            print_success "Deploy no GitHub Pages concluído!"
            print_info "Ative o GitHub Pages em: Settings → Pages → Source: gh-pages"
        else
            print_error "Falha no deploy do GitHub Pages!"
            exit 1
        fi
        ;;
        
    build-only)
        print_success "Build concluído! Arquivos em: build/web"
        print_info "Você pode fazer upload manual para qualquer serviço de hosting"
        ;;
esac

echo ""
print_success "🎉 Processo concluído com sucesso!"
echo ""
