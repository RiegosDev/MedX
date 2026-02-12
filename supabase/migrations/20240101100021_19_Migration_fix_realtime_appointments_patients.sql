-- Descrição: Corrige Realtime para agendamentos e pacientes
-- Versão corrigida para evitar erro de sintaxe "IF EXISTS"

DO $$
BEGIN
    -- Tenta remover APPOINTMENTS da publicação (ignora erro se não estiver lá)
    BEGIN
        ALTER PUBLICATION supabase_realtime DROP TABLE public.appointments;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;

    -- Tenta remover PATIENTS da publicação (ignora erro se não estiver lá)
    BEGIN
        ALTER PUBLICATION supabase_realtime DROP TABLE public.patients;
    EXCEPTION WHEN OTHERS THEN
        NULL;
    END;
END $$;

-- Agora adiciona novamente para garantir que o Realtime funcione
ALTER PUBLICATION supabase_realtime ADD TABLE public.appointments;
ALTER PUBLICATION supabase_realtime ADD TABLE public.patients;