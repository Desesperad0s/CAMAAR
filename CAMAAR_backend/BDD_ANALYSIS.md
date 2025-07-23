# Relatório: Problemas nos Testes BDD

## Principais Problemas Identificados:

### 1. Incompatibilidade API vs Frontend (CRÍTICO)
**Problema:** Testes tentam acessar rotas de frontend (/login, /templates, etc) em uma API Rails
**Solução:** 
- Separar testes de API (backend) dos testes de interface (frontend)
- Ou configurar testes end-to-end que incluam ambos os ambientes

### 2. Step Definitions Desatualizados
**Problema:** Steps tentam interagir com elementos HTML inexistentes
**Soluções:**
- Atualizar steps para usar APIs REST
- Ou implementar views Rails para os controllers

### 3. Problemas de Autenticação nos Testes
**Problema:** Status 401 em vez de 200 em logins válidos
**Causas possíveis:**
- Usuários não sendo criados corretamente nos testes
- Senha não sendo criptografada/comparada corretamente
- Falta de configuração de ambiente de teste

### 4. Dados de Teste Incompletos
**Problema:** Validações de modelo falhando (ex: Disciplina must exist)
**Solução:** Usar FactoryBot ou fixtures adequados

## Recomendações Imediatas:

1. **Decidir a arquitetura de teste:**
   - Testes de API pura (sem Capybara)
   - Testes end-to-end (API + Frontend)

2. **Corrigir autenticação:**
   - Verificar método User.authenticate
   - Configurar ambiente de teste adequadamente

3. **Implementar step undefined:**
   ```ruby
   Então('eu devo visualizar uma mensagem dizendo  {string}') do |mensagem|
     expect(page).to have_content(mensagem)
   end
   ```

4. **Usar factories para dados de teste:**
   - Criar FactoryBot factories consistentes
   - Garantir relacionamentos necessários

## Status Atual:
- 38 cenários falhando
- 2 cenários passando  
- 1 step indefinido
- Maioria dos problemas são de infraestrutura, não lógica de negócio
