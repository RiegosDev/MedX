-- Descrição: Correção de recursão infinita nas políticas RLS da tabela profiles
-- Data: 2025-10-24
-- Autor: Sistema MedX - Correção de Segurança

-- ====================================================================================
-- ETAPA 1: REMOVER POLÍTICAS COM RECURSÃO
-- ====================================================================================

DROP POLICY IF EXISTS "authenticated_users_can_view_all_profiles" ON profiles;
DROP POLICY IF EXISTS "owners_can_insert_profiles" ON profiles;
DROP POLICY IF EXISTS "users_can_update_own_profile_or_owner_all" ON profiles;
DROP POLICY IF EXISTS "only_owners_can_delete_profiles" ON profiles;
DROP POLICY IF EXISTS "Users can read own profile" ON profiles;

-- ====================================================================================
-- ETAPA 2: CRIAR FUNÇÃO AUXILIAR SEM RECURSÃO
-- ====================================================================================

CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
STABLE
AS $$
DECLARE
  user_role TEXT;
BEGIN
  SELECT role INTO user_role
  FROM profiles
  WHERE auth_user_id = auth.uid()
  LIMIT 1;
  
  RETURN COALESCE(user_role, '');
END;
$$;

COMMENT ON FUNCTION get_user_role() IS 
  'Retorna a role do usuário autenticado sem causar recursão nas políticas RLS. Usa SECURITY DEFINER.';

-- ====================================================================================
-- ETAPA 3: CRIAR POLÍTICAS RLS SEM RECURSÃO
-- ====================================================================================

-- POLÍTICA SELECT
CREATE POLICY "select_profiles_authenticated" ON profiles
  FOR SELECT
  TO authenticated
  USING (true);

-- POLÍTICA INSERT
CREATE POLICY "insert_profiles_owner_only" ON profiles
  FOR INSERT
  TO authenticated
  WITH CHECK (get_user_role() = 'owner');

-- POLÍTICA UPDATE
CREATE POLICY "update_profiles_own_or_owner" ON profiles
  FOR UPDATE
  TO authenticated
  USING (
    auth_user_id = auth.uid() OR
    get_user_role() = 'owner'
  )
  WITH CHECK (
    auth_user_id = auth.uid() OR
    get_user_role() = 'owner'
  );

-- POLÍTICA DELETE
CREATE POLICY "delete_profiles_owner_only" ON profiles
  FOR DELETE
  TO authenticated
  USING (get_user_role() = 'owner');