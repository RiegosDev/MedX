-- Descrição: Garante que a coluna media seja do tipo TEXT
-- Simplificado para evitar erros de conversão em banco novo

DO $$
BEGIN
    -- Só altera se a coluna existir
    IF EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'medx_history' AND column_name = 'media') THEN
        ALTER TABLE public.medx_history ALTER COLUMN media TYPE text USING media::text;
    END IF;
END $$;