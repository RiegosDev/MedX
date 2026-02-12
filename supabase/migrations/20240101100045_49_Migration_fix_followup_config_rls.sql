-- Descrição: Correção das políticas RLS da tabela followup_config
-- Data: 2025-10-27
-- Autor: Sistema MedX

-- 1. LIMPEZA TOTAL (Remove regras antigas e novas para evitar conflitos)
DROP POLICY IF EXISTS "Owner pode gerenciar configuração de follow-up" ON followup_config;
DROP POLICY IF EXISTS "Doctor e Secretary podem ler configuração de follow-up" ON followup_config;
DROP POLICY IF EXISTS "Todos autenticados podem ler configuração" ON followup_config;
DROP POLICY IF EXISTS "Todos autenticados podem criar configuração" ON followup_config;
DROP POLICY IF EXISTS "Todos autenticados podem atualizar configuração" ON followup_config;
DROP POLICY IF EXISTS "Apenas owner pode deletar configuração" ON followup_config;

-- 2. RECRIAR POLÍTICAS (Regras simplificadas)

-- LEITURA (SELECT)
CREATE POLICY "Todos autenticados podem ler configuração"
ON followup_config FOR SELECT TO authenticated
USING (true);

-- CRIAÇÃO (INSERT)
CREATE POLICY "Todos autenticados podem criar configuração"
ON followup_config FOR INSERT TO authenticated
WITH CHECK (true);

-- ATUALIZAÇÃO (UPDATE)
CREATE POLICY "Todos autenticados podem atualizar configuração"
ON followup_config FOR UPDATE TO authenticated
USING (true) WITH CHECK (true);

-- DELEÇÃO (DELETE) - Apenas Owner
CREATE POLICY "Apenas owner pode deletar configuração"
ON followup_config FOR DELETE TO authenticated
USING (
  EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'owner')
);