using System;

namespace RastaQuest.Core
{
    public enum ReviewLabel { Language, ReduceShadow, RestoreShadow, Continue, RestoreHealth, QuickHands, StrongAxe,
        Health, Healed, Defeated, Restart, RestartHint, Encounter, Rewards, PortalReady, Transition, Paused }
    public static class ReviewText
    {
        private static readonly string[] Portuguese = {
            "Idioma: Português", "Reduzir sombra", "Restaurar sombra", "Continuar", "Restaurar vida",
            "Mãos ágeis", "Machado forte", "Vida", "Vida restaurada", "Você foi derrotado", "Tentar novamente",
            "Recomeçar na Floresta, com vida cheia e sem melhorias.",
            "Derrote os inimigos e alcance o portal", "Escolha uma melhoria", "Portal aberto — siga até ele",
            "Atravessando o portal…", "Jogo pausado"
        };
        private static readonly string[] Spanish = {
            "Idioma: Español", "Reducir sombra", "Restaurar sombra", "Continuar", "Restaurar vida",
            "Manos ágiles", "Hacha fuerte", "Vida", "Vida restaurada", "Has sido derrotado", "Volver a intentar",
            "Volver al Bosque, con toda la vida y sin mejoras.",
            "Derrota a los enemigos y alcanza el portal", "Elige una mejora", "Portal abierto — acércate",
            "Atravesando el portal…", "Juego pausado"
        };
        public static string Get(ReviewLabel label, bool spanish)
        {
            int index = (int)label;
            if (index < 0 || index >= Portuguese.Length) throw new ArgumentOutOfRangeException("label");
            return (spanish ? Spanish : Portuguese)[index];
        }
    }
}
