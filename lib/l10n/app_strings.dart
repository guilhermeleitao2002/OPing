import 'package:oping/models/app_language.dart';

class AppStrings {
  final AppLanguage language;
  const AppStrings(this.language);

  // ── Shared ─────────────────────────────────────────────────────────────────

  String get cancel => switch (language) {
        AppLanguage.english    => 'Cancel',
        AppLanguage.french     => 'Annuler',
        AppLanguage.spanish    => 'Cancelar',
        AppLanguage.italian    => 'Annulla',
        AppLanguage.german     => 'Abbrechen',
        AppLanguage.portuguese => 'Cancelar',
        AppLanguage.japanese   => 'Cancel', // TODO: native review needed
        AppLanguage.chinese    => 'Cancel', // TODO: native review needed
      };

  String get retry => switch (language) {
        AppLanguage.english    => 'Retry',
        AppLanguage.french     => 'Réessayer',
        AppLanguage.spanish    => 'Reintentar',
        AppLanguage.italian    => 'Riprova',
        AppLanguage.german     => 'Erneut versuchen',
        AppLanguage.portuguese => 'Tentar novamente',
        AppLanguage.japanese   => 'Retry', // TODO: native review needed
        AppLanguage.chinese    => 'Retry', // TODO: native review needed
      };

  String get untrack => switch (language) {
        AppLanguage.english    => 'Untrack',
        AppLanguage.french     => 'Désabonner',
        AppLanguage.spanish    => 'Dejar de seguir',
        AppLanguage.italian    => 'Rimuovi',
        AppLanguage.german     => 'Entfolgen',
        AppLanguage.portuguese => 'Parar de seguir',
        AppLanguage.japanese   => 'Untrack', // TODO: native review needed
        AppLanguage.chinese    => 'Untrack', // TODO: native review needed
      };

  String get openSettings => switch (language) {
        AppLanguage.english    => 'Open Settings',
        AppLanguage.french     => 'Ouvrir les paramètres',
        AppLanguage.spanish    => 'Abrir ajustes',
        AppLanguage.italian    => 'Apri impostazioni',
        AppLanguage.german     => 'Einstellungen öffnen',
        AppLanguage.portuguese => 'Abrir configurações',
        AppLanguage.japanese   => 'Open Settings', // TODO: native review needed
        AppLanguage.chinese    => 'Open Settings', // TODO: native review needed
      };

  // ── HomeScreen ─────────────────────────────────────────────────────────────

  String get appTitle => switch (language) {
        AppLanguage.english    => 'OPing',
        AppLanguage.french     => 'OPing',
        AppLanguage.spanish    => 'OPing',
        AppLanguage.italian    => 'OPing',
        AppLanguage.german     => 'OPing',
        AppLanguage.portuguese => 'OPing',
        AppLanguage.japanese   => 'OPing',
        AppLanguage.chinese    => 'OPing',
      };

  String get checkNow => switch (language) {
        AppLanguage.english    => 'Check now',
        AppLanguage.french     => 'Vérifier maintenant',
        AppLanguage.spanish    => 'Verificar ahora',
        AppLanguage.italian    => 'Controlla ora',
        AppLanguage.german     => 'Jetzt prüfen',
        AppLanguage.portuguese => 'Verificar agora',
        AppLanguage.japanese   => 'Check now', // TODO: native review needed
        AppLanguage.chinese    => 'Check now', // TODO: native review needed
      };

  String get reload => switch (language) {
        AppLanguage.english    => 'Reload',
        AppLanguage.french     => 'Recharger',
        AppLanguage.spanish    => 'Recargar',
        AppLanguage.italian    => 'Ricarica',
        AppLanguage.german     => 'Neu laden',
        AppLanguage.portuguese => 'Recarregar',
        AppLanguage.japanese   => 'Reload', // TODO: native review needed
        AppLanguage.chinese    => 'Reload', // TODO: native review needed
      };

  String get addManga => switch (language) {
        AppLanguage.english    => 'Add manga',
        AppLanguage.french     => 'Ajouter un manga',
        AppLanguage.spanish    => 'Agregar manga',
        AppLanguage.italian    => 'Aggiungi manga',
        AppLanguage.german     => 'Manga hinzufügen',
        AppLanguage.portuguese => 'Adicionar manga',
        AppLanguage.japanese   => 'Add manga', // TODO: native review needed
        AppLanguage.chinese    => 'Add manga', // TODO: native review needed
      };

  String get trackedMangaTitle => switch (language) {
        AppLanguage.english    => 'Tracked manga',
        AppLanguage.french     => 'Manga suivis',
        AppLanguage.spanish    => 'Manga seguidos',
        AppLanguage.italian    => 'Manga seguiti',
        AppLanguage.german     => 'Verfolgte Manga',
        AppLanguage.portuguese => 'Manga seguidos',
        AppLanguage.japanese   => 'Tracked manga', // TODO: native review needed
        AppLanguage.chinese    => 'Tracked manga', // TODO: native review needed
      };

  String get noMangaTracked => switch (language) {
        AppLanguage.english    => 'No manga tracked yet',
        AppLanguage.french     => 'Aucun manga suivi',
        AppLanguage.spanish    => 'Ningún manga seguido aún',
        AppLanguage.italian    => 'Nessun manga seguito',
        AppLanguage.german     => 'Noch keine Manga verfolgt',
        AppLanguage.portuguese => 'Nenhum manga seguido ainda',
        AppLanguage.japanese   => 'No manga tracked yet', // TODO: native review needed
        AppLanguage.chinese    => 'No manga tracked yet', // TODO: native review needed
      };

  String get noMangaTrackedHint => switch (language) {
        AppLanguage.english    => 'Tap + to find a manga and start receiving notifications.',
        AppLanguage.french     => 'Appuyez sur + pour trouver un manga et recevoir des notifications.',
        AppLanguage.spanish    => 'Toca + para encontrar un manga y empezar a recibir notificaciones.',
        AppLanguage.italian    => 'Premi + per trovare un manga e ricevere notifiche.',
        AppLanguage.german     => 'Tippe auf +, um einen Manga zu finden und Benachrichtigungen zu erhalten.',
        AppLanguage.portuguese => 'Toque em + para encontrar um manga e começar a receber notificações.',
        AppLanguage.japanese   => 'Tap + to find a manga and start receiving notifications.', // TODO: native review needed
        AppLanguage.chinese    => 'Tap + to find a manga and start receiving notifications.', // TODO: native review needed
      };

  String get neverChecked => switch (language) {
        AppLanguage.english    => 'Never checked via background',
        AppLanguage.french     => 'Jamais vérifié en arrière-plan',
        AppLanguage.spanish    => 'Nunca verificado en segundo plano',
        AppLanguage.italian    => 'Mai controllato in background',
        AppLanguage.german     => 'Noch nie im Hintergrund geprüft',
        AppLanguage.portuguese => 'Nunca verificado em segundo plano',
        AppLanguage.japanese   => 'Never checked via background', // TODO: native review needed
        AppLanguage.chinese    => 'Never checked via background', // TODO: native review needed
      };

  String lastCheckedAgo(String t) => switch (language) {
        AppLanguage.english    => 'Last background check: $t',
        AppLanguage.french     => 'Dernière vérification : $t',
        AppLanguage.spanish    => 'Última verificación: hace $t',
        AppLanguage.italian    => 'Ultimo controllo: $t fa',
        AppLanguage.german     => 'Letzte Prüfung: vor $t',
        AppLanguage.portuguese => 'Última verificação: $t atrás',
        AppLanguage.japanese   => 'Last background check: $t', // TODO: native review needed
        AppLanguage.chinese    => 'Last background check: $t', // TODO: native review needed
      };

  String get justNow => switch (language) {
        AppLanguage.english    => 'just now',
        AppLanguage.french     => 'à l\'instant',
        AppLanguage.spanish    => 'justo ahora',
        AppLanguage.italian    => 'proprio ora',
        AppLanguage.german     => 'gerade eben',
        AppLanguage.portuguese => 'agora mesmo',
        AppLanguage.japanese   => 'just now', // TODO: native review needed
        AppLanguage.chinese    => 'just now', // TODO: native review needed
      };

  String minutesAgo(int n) => switch (language) {
        AppLanguage.english    => '${n}m ago',
        AppLanguage.french     => 'il y a $n min',
        AppLanguage.spanish    => 'hace $n min',
        AppLanguage.italian    => '$n min fa',
        AppLanguage.german     => 'vor $n Min.',
        AppLanguage.portuguese => 'há $n min',
        AppLanguage.japanese   => '${n}m ago', // TODO: native review needed
        AppLanguage.chinese    => '${n}m ago', // TODO: native review needed
      };

  String hoursAgo(int n) => switch (language) {
        AppLanguage.english    => '${n}h ago',
        AppLanguage.french     => 'il y a $n h',
        AppLanguage.spanish    => 'hace $n h',
        AppLanguage.italian    => '$n h fa',
        AppLanguage.german     => 'vor $n Std.',
        AppLanguage.portuguese => 'há $n h',
        AppLanguage.japanese   => '${n}h ago', // TODO: native review needed
        AppLanguage.chinese    => '${n}h ago', // TODO: native review needed
      };

  String daysAgo(int n) => switch (language) {
        AppLanguage.english    => '${n}d ago',
        AppLanguage.french     => 'il y a $n j',
        AppLanguage.spanish    => 'hace $n días',
        AppLanguage.italian    => '$n g fa',
        AppLanguage.german     => 'vor $n Tagen',
        AppLanguage.portuguese => 'há $n dias',
        AppLanguage.japanese   => '${n}d ago', // TODO: native review needed
        AppLanguage.chinese    => '${n}d ago', // TODO: native review needed
      };

  String get backgroundPolling => switch (language) {
        AppLanguage.english    => 'Background polling',
        AppLanguage.french     => 'Vérification en arrière-plan',
        AppLanguage.spanish    => 'Verificación en segundo plano',
        AppLanguage.italian    => 'Controllo in background',
        AppLanguage.german     => 'Hintergrundabfrage',
        AppLanguage.portuguese => 'Verificação em segundo plano',
        AppLanguage.japanese   => 'Background polling', // TODO: native review needed
        AppLanguage.chinese    => 'Background polling', // TODO: native review needed
      };

  String checksEvery(String interval) => switch (language) {
        AppLanguage.english    => 'Checks for new chapters every $interval',
        AppLanguage.french     => 'Vérifie les nouveaux chapitres toutes les $interval',
        AppLanguage.spanish    => 'Busca nuevos capítulos cada $interval',
        AppLanguage.italian    => 'Controlla nuovi capitoli ogni $interval',
        AppLanguage.german     => 'Prüft alle $interval auf neue Kapitel',
        AppLanguage.portuguese => 'Verifica novos capítulos a cada $interval',
        AppLanguage.japanese   => 'Checks for new chapters every $interval', // TODO: native review needed
        AppLanguage.chinese    => 'Checks for new chapters every $interval', // TODO: native review needed
      };

  String get notificationsPaused => switch (language) {
        AppLanguage.english    => 'Notifications paused',
        AppLanguage.french     => 'Notifications en pause',
        AppLanguage.spanish    => 'Notificaciones pausadas',
        AppLanguage.italian    => 'Notifiche in pausa',
        AppLanguage.german     => 'Benachrichtigungen pausiert',
        AppLanguage.portuguese => 'Notificações pausadas',
        AppLanguage.japanese   => 'Notifications paused', // TODO: native review needed
        AppLanguage.chinese    => 'Notifications paused', // TODO: native review needed
      };

  String get checkInterval => switch (language) {
        AppLanguage.english    => 'Check interval',
        AppLanguage.french     => 'Intervalle de vérification',
        AppLanguage.spanish    => 'Intervalo de verificación',
        AppLanguage.italian    => 'Intervallo di controllo',
        AppLanguage.german     => 'Prüfintervall',
        AppLanguage.portuguese => 'Intervalo de verificação',
        AppLanguage.japanese   => 'Check interval', // TODO: native review needed
        AppLanguage.chinese    => 'Check interval', // TODO: native review needed
      };

  String get readingLanguage => switch (language) {
        AppLanguage.english    => 'Reading language',
        AppLanguage.french     => 'Langue de lecture',
        AppLanguage.spanish    => 'Idioma de lectura',
        AppLanguage.italian    => 'Lingua di lettura',
        AppLanguage.german     => 'Lesesprache',
        AppLanguage.portuguese => 'Idioma de leitura',
        AppLanguage.japanese   => 'Reading language', // TODO: native review needed
        AppLanguage.chinese    => 'Reading language', // TODO: native review needed
      };

  String get untrackDialogTitle => switch (language) {
        AppLanguage.english    => 'Untrack manga?',
        AppLanguage.french     => 'Désabonner ce manga ?',
        AppLanguage.spanish    => '¿Dejar de seguir el manga?',
        AppLanguage.italian    => 'Rimuovere il manga?',
        AppLanguage.german     => 'Manga entfolgen?',
        AppLanguage.portuguese => 'Parar de seguir o manga?',
        AppLanguage.japanese   => 'Untrack manga?', // TODO: native review needed
        AppLanguage.chinese    => 'Untrack manga?', // TODO: native review needed
      };

  String untrackDialogBody(String title) => switch (language) {
        AppLanguage.english    => 'Stop receiving notifications for $title?',
        AppLanguage.french     => 'Arrêter les notifications pour $title ?',
        AppLanguage.spanish    => '¿Dejar de recibir notificaciones de $title?',
        AppLanguage.italian    => 'Smettere di ricevere notifiche per $title?',
        AppLanguage.german     => 'Keine Benachrichtigungen mehr für $title?',
        AppLanguage.portuguese => 'Parar de receber notificações de $title?',
        AppLanguage.japanese   => 'Stop receiving notifications for $title?', // TODO: native review needed
        AppLanguage.chinese    => 'Stop receiving notifications for $title?', // TODO: native review needed
      };

  String get notificationsDisabledTitle => switch (language) {
        AppLanguage.english    => 'Notifications Disabled',
        AppLanguage.french     => 'Notifications désactivées',
        AppLanguage.spanish    => 'Notificaciones desactivadas',
        AppLanguage.italian    => 'Notifiche disabilitate',
        AppLanguage.german     => 'Benachrichtigungen deaktiviert',
        AppLanguage.portuguese => 'Notificações desativadas',
        AppLanguage.japanese   => 'Notifications Disabled', // TODO: native review needed
        AppLanguage.chinese    => 'Notifications Disabled', // TODO: native review needed
      };

  String get notificationsDisabledBody => switch (language) {
        AppLanguage.english    =>
            'OPing needs notification permission to alert you about new chapters. '
            'Please enable it in app settings.',
        AppLanguage.french     =>
            'OPing a besoin de la permission de notifications pour vous alerter des nouveaux chapitres. '
            'Veuillez l\'activer dans les paramètres.',
        AppLanguage.spanish    =>
            'OPing necesita permiso de notificaciones para alertarte sobre nuevos capítulos. '
            'Actívalo en los ajustes de la app.',
        AppLanguage.italian    =>
            'OPing ha bisogno del permesso per le notifiche per avvisarti dei nuovi capitoli. '
            'Abilitalo nelle impostazioni dell\'app.',
        AppLanguage.german     =>
            'OPing benötigt die Benachrichtigungsberechtigung, um dich über neue Kapitel zu informieren. '
            'Bitte in den App-Einstellungen aktivieren.',
        AppLanguage.portuguese =>
            'OPing precisa de permissão de notificações para alertar sobre novos capítulos. '
            'Ative nas configurações do app.',
        AppLanguage.japanese   =>
            'OPing needs notification permission to alert you about new chapters. '
            'Please enable it in app settings.', // TODO: native review needed
        AppLanguage.chinese    =>
            'OPing needs notification permission to alert you about new chapters. '
            'Please enable it in app settings.', // TODO: native review needed
      };

  String intervalLabel(int minutes) {
    if (minutes < 60) {
      return switch (language) {
        AppLanguage.english    => '$minutes min',
        AppLanguage.french     => '$minutes min',
        AppLanguage.spanish    => '$minutes min',
        AppLanguage.italian    => '$minutes min',
        AppLanguage.german     => '$minutes Min.',
        AppLanguage.portuguese => '$minutes min',
        AppLanguage.japanese   => '$minutes min',
        AppLanguage.chinese    => '$minutes min',
      };
    }
    final h = minutes ~/ 60;
    if (h == 1) {
      return switch (language) {
        AppLanguage.english    => '1 hour',
        AppLanguage.french     => '1 heure',
        AppLanguage.spanish    => '1 hora',
        AppLanguage.italian    => '1 ora',
        AppLanguage.german     => '1 Stunde',
        AppLanguage.portuguese => '1 hora',
        AppLanguage.japanese   => '1 hour', // TODO: native review needed
        AppLanguage.chinese    => '1 hour', // TODO: native review needed
      };
    }
    return switch (language) {
      AppLanguage.english    => '$h hours',
      AppLanguage.french     => '$h heures',
      AppLanguage.spanish    => '$h horas',
      AppLanguage.italian    => '$h ore',
      AppLanguage.german     => '$h Stunden',
      AppLanguage.portuguese => '$h horas',
      AppLanguage.japanese   => '$h hours', // TODO: native review needed
      AppLanguage.chinese    => '$h hours', // TODO: native review needed
    };
  }

  // ── MangaCard ──────────────────────────────────────────────────────────────

  String lastSeenChapter(String n) => switch (language) {
        AppLanguage.english    => 'Last seen: Chapter $n',
        AppLanguage.french     => 'Dernier lu : Chapitre $n',
        AppLanguage.spanish    => 'Último visto: Capítulo $n',
        AppLanguage.italian    => 'Ultimo letto: Capitolo $n',
        AppLanguage.german     => 'Zuletzt: Kapitel $n',
        AppLanguage.portuguese => 'Último visto: Capítulo $n',
        AppLanguage.japanese   => 'Last seen: Chapter $n', // TODO: native review needed
        AppLanguage.chinese    => 'Last seen: Chapter $n', // TODO: native review needed
      };

  String get noChaptersSeen => switch (language) {
        AppLanguage.english    => 'No chapters seen yet',
        AppLanguage.french     => 'Aucun chapitre lu',
        AppLanguage.spanish    => 'Ningún capítulo visto aún',
        AppLanguage.italian    => 'Nessun capitolo letto',
        AppLanguage.german     => 'Noch keine Kapitel gelesen',
        AppLanguage.portuguese => 'Nenhum capítulo visto ainda',
        AppLanguage.japanese   => 'No chapters seen yet', // TODO: native review needed
        AppLanguage.chinese    => 'No chapters seen yet', // TODO: native review needed
      };

  // ── MangaSearchScreen ──────────────────────────────────────────────────────

  String get searchHint => switch (language) {
        AppLanguage.english    => 'Search MangaDex by title…',
        AppLanguage.french     => 'Rechercher sur MangaDex…',
        AppLanguage.spanish    => 'Buscar en MangaDex por título…',
        AppLanguage.italian    => 'Cerca su MangaDex per titolo…',
        AppLanguage.german     => 'MangaDex nach Titel durchsuchen…',
        AppLanguage.portuguese => 'Pesquisar no MangaDex por título…',
        AppLanguage.japanese   => 'Search MangaDex by title…', // TODO: native review needed
        AppLanguage.chinese    => 'Search MangaDex by title…', // TODO: native review needed
      };

  String get relevanceLabel => switch (language) {
        AppLanguage.english    => 'Relevance',
        AppLanguage.french     => 'Pertinence',
        AppLanguage.spanish    => 'Relevancia',
        AppLanguage.italian    => 'Rilevanza',
        AppLanguage.german     => 'Relevanz',
        AppLanguage.portuguese => 'Relevância',
        AppLanguage.japanese   => 'Relevance', // TODO: native review needed
        AppLanguage.chinese    => 'Relevance', // TODO: native review needed
      };

  String get mostPopularLabel => switch (language) {
        AppLanguage.english    => 'Most Popular',
        AppLanguage.french     => 'Les plus populaires',
        AppLanguage.spanish    => 'Más popular',
        AppLanguage.italian    => 'Più popolari',
        AppLanguage.german     => 'Beliebteste',
        AppLanguage.portuguese => 'Mais popular',
        AppLanguage.japanese   => 'Most Popular', // TODO: native review needed
        AppLanguage.chinese    => 'Most Popular', // TODO: native review needed
      };

  String get topRatedLabel => switch (language) {
        AppLanguage.english    => 'Top Rated',
        AppLanguage.french     => 'Mieux notés',
        AppLanguage.spanish    => 'Mejor valorados',
        AppLanguage.italian    => 'Meglio valutati',
        AppLanguage.german     => 'Bestbewertet',
        AppLanguage.portuguese => 'Melhor avaliados',
        AppLanguage.japanese   => 'Top Rated', // TODO: native review needed
        AppLanguage.chinese    => 'Top Rated', // TODO: native review needed
      };

  String get recentlyUpdatedLabel => switch (language) {
        AppLanguage.english    => 'Recently Updated',
        AppLanguage.french     => 'Récemment mis à jour',
        AppLanguage.spanish    => 'Actualizado recientemente',
        AppLanguage.italian    => 'Aggiornati di recente',
        AppLanguage.german     => 'Zuletzt aktualisiert',
        AppLanguage.portuguese => 'Atualizado recentemente',
        AppLanguage.japanese   => 'Recently Updated', // TODO: native review needed
        AppLanguage.chinese    => 'Recently Updated', // TODO: native review needed
      };

  String get newestLabel => switch (language) {
        AppLanguage.english    => 'Newest',
        AppLanguage.french     => 'Les plus récents',
        AppLanguage.spanish    => 'Más nuevos',
        AppLanguage.italian    => 'Più recenti',
        AppLanguage.german     => 'Neueste',
        AppLanguage.portuguese => 'Mais novos',
        AppLanguage.japanese   => 'Newest', // TODO: native review needed
        AppLanguage.chinese    => 'Newest', // TODO: native review needed
      };

  String get popularOnMangaDex => switch (language) {
        AppLanguage.english    => 'Popular on MangaDex',
        AppLanguage.french     => 'Populaires sur MangaDex',
        AppLanguage.spanish    => 'Popular en MangaDex',
        AppLanguage.italian    => 'Popolari su MangaDex',
        AppLanguage.german     => 'Beliebt auf MangaDex',
        AppLanguage.portuguese => 'Popular no MangaDex',
        AppLanguage.japanese   => 'Popular on MangaDex', // TODO: native review needed
        AppLanguage.chinese    => 'Popular on MangaDex', // TODO: native review needed
      };

  String get searchPrompt => switch (language) {
        AppLanguage.english    => 'Search for a manga above',
        AppLanguage.french     => 'Recherchez un manga ci-dessus',
        AppLanguage.spanish    => 'Busca un manga arriba',
        AppLanguage.italian    => 'Cerca un manga qui sopra',
        AppLanguage.german     => 'Oben nach einem Manga suchen',
        AppLanguage.portuguese => 'Pesquise um manga acima',
        AppLanguage.japanese   => 'Search for a manga above', // TODO: native review needed
        AppLanguage.chinese    => 'Search for a manga above', // TODO: native review needed
      };

  String noResultsFor(String q) => switch (language) {
        AppLanguage.english    => 'No results for "$q"',
        AppLanguage.french     => 'Aucun résultat pour « $q »',
        AppLanguage.spanish    => 'Sin resultados para "$q"',
        AppLanguage.italian    => 'Nessun risultato per "$q"',
        AppLanguage.german     => 'Keine Ergebnisse für „$q"',
        AppLanguage.portuguese => 'Nenhum resultado para "$q"',
        AppLanguage.japanese   => 'No results for "$q"', // TODO: native review needed
        AppLanguage.chinese    => 'No results for "$q"', // TODO: native review needed
      };

  String nowTracking(String title) => switch (language) {
        AppLanguage.english    => 'Now tracking $title',
        AppLanguage.french     => 'Suivi de $title activé',
        AppLanguage.spanish    => 'Ahora siguiendo $title',
        AppLanguage.italian    => 'Ora segui $title',
        AppLanguage.german     => '$title wird jetzt verfolgt',
        AppLanguage.portuguese => 'Agora seguindo $title',
        AppLanguage.japanese   => 'Now tracking $title', // TODO: native review needed
        AppLanguage.chinese    => 'Now tracking $title', // TODO: native review needed
      };

  String get trackedLabel => switch (language) {
        AppLanguage.english    => 'Tracked',
        AppLanguage.french     => 'Suivi',
        AppLanguage.spanish    => 'Seguido',
        AppLanguage.italian    => 'Seguito',
        AppLanguage.german     => 'Verfolgt',
        AppLanguage.portuguese => 'Seguido',
        AppLanguage.japanese   => 'Tracked', // TODO: native review needed
        AppLanguage.chinese    => 'Tracked', // TODO: native review needed
      };

  String get trackLabel => switch (language) {
        AppLanguage.english    => 'Track',
        AppLanguage.french     => 'Suivre',
        AppLanguage.spanish    => 'Seguir',
        AppLanguage.italian    => 'Segui',
        AppLanguage.german     => 'Verfolgen',
        AppLanguage.portuguese => 'Seguir',
        AppLanguage.japanese   => 'Track', // TODO: native review needed
        AppLanguage.chinese    => 'Track', // TODO: native review needed
      };

  // ── ChapterListScreen ──────────────────────────────────────────────────────

  String get openInMangaDex => switch (language) {
        AppLanguage.english    => 'Open in MangaDex',
        AppLanguage.french     => 'Ouvrir sur MangaDex',
        AppLanguage.spanish    => 'Abrir en MangaDex',
        AppLanguage.italian    => 'Apri su MangaDex',
        AppLanguage.german     => 'In MangaDex öffnen',
        AppLanguage.portuguese => 'Abrir no MangaDex',
        AppLanguage.japanese   => 'Open in MangaDex', // TODO: native review needed
        AppLanguage.chinese    => 'Open in MangaDex', // TODO: native review needed
      };

  String get failedToLoadChapters => switch (language) {
        AppLanguage.english    => 'Failed to load chapters.',
        AppLanguage.french     => 'Impossible de charger les chapitres.',
        AppLanguage.spanish    => 'Error al cargar los capítulos.',
        AppLanguage.italian    => 'Impossibile caricare i capitoli.',
        AppLanguage.german     => 'Kapitel konnten nicht geladen werden.',
        AppLanguage.portuguese => 'Falha ao carregar os capítulos.',
        AppLanguage.japanese   => 'Failed to load chapters.', // TODO: native review needed
        AppLanguage.chinese    => 'Failed to load chapters.', // TODO: native review needed
      };

  String noChaptersFound(String lang) => switch (language) {
        AppLanguage.english    => 'No $lang chapters found from any source.',
        AppLanguage.french     => 'Aucun chapitre en $lang trouvé.',
        AppLanguage.spanish    => 'No se encontraron capítulos en $lang.',
        AppLanguage.italian    => 'Nessun capitolo in $lang trovato.',
        AppLanguage.german     => 'Keine $lang-Kapitel gefunden.',
        AppLanguage.portuguese => 'Nenhum capítulo em $lang encontrado.',
        AppLanguage.japanese   => 'No $lang chapters found from any source.', // TODO: native review needed
        AppLanguage.chinese    => 'No $lang chapters found from any source.', // TODO: native review needed
      };

  String get availableLanguages => switch (language) {
        AppLanguage.english    => 'Available languages:',
        AppLanguage.french     => 'Langues disponibles :',
        AppLanguage.spanish    => 'Idiomas disponibles:',
        AppLanguage.italian    => 'Lingue disponibili:',
        AppLanguage.german     => 'Verfügbare Sprachen:',
        AppLanguage.portuguese => 'Idiomas disponíveis:',
        AppLanguage.japanese   => 'Available languages:', // TODO: native review needed
        AppLanguage.chinese    => 'Available languages:', // TODO: native review needed
      };

  String get chaptersHostedExternally => switch (language) {
        AppLanguage.english    => 'The manga may host chapters externally.',
        AppLanguage.french     => 'Le manga héberge peut-être ses chapitres en externe.',
        AppLanguage.spanish    => 'El manga puede alojar capítulos en otro sitio.',
        AppLanguage.italian    => 'Il manga potrebbe ospitare i capitoli esternamente.',
        AppLanguage.german     => 'Die Kapitel könnten extern gehostet sein.',
        AppLanguage.portuguese => 'O manga pode hospedar capítulos externamente.',
        AppLanguage.japanese   => 'The manga may host chapters externally.', // TODO: native review needed
        AppLanguage.chinese    => 'The manga may host chapters externally.', // TODO: native review needed
      };

  String get viewOnMangaDex => switch (language) {
        AppLanguage.english    => 'View on MangaDex',
        AppLanguage.french     => 'Voir sur MangaDex',
        AppLanguage.spanish    => 'Ver en MangaDex',
        AppLanguage.italian    => 'Vedi su MangaDex',
        AppLanguage.german     => 'Auf MangaDex ansehen',
        AppLanguage.portuguese => 'Ver no MangaDex',
        AppLanguage.japanese   => 'View on MangaDex', // TODO: native review needed
        AppLanguage.chinese    => 'View on MangaDex', // TODO: native review needed
      };

  String chapterCount(int n, String lang) => switch (language) {
        AppLanguage.english    => '$n $lang ${n == 1 ? 'chapter' : 'chapters'}',
        AppLanguage.french     => '$n ${n == 1 ? 'chapitre' : 'chapitres'} en $lang',
        AppLanguage.spanish    => '$n ${n == 1 ? 'capítulo' : 'capítulos'} en $lang',
        AppLanguage.italian    => '$n ${n == 1 ? 'capitolo' : 'capitoli'} in $lang',
        AppLanguage.german     => '$n $lang-${n == 1 ? 'Kapitel' : 'Kapitel'}',
        AppLanguage.portuguese => '$n ${n == 1 ? 'capítulo' : 'capítulos'} em $lang',
        AppLanguage.japanese   => '$n $lang ${n == 1 ? 'chapter' : 'chapters'}', // TODO: native review needed
        AppLanguage.chinese    => '$n $lang ${n == 1 ? 'chapter' : 'chapters'}', // TODO: native review needed
      };

  String chapterWithTitle(String num, String title) => switch (language) {
        AppLanguage.english    => 'Ch. $num: $title',
        AppLanguage.french     => 'Ch. $num : $title',
        AppLanguage.spanish    => 'Cap. $num: $title',
        AppLanguage.italian    => 'Cap. $num: $title',
        AppLanguage.german     => 'Kap. $num: $title',
        AppLanguage.portuguese => 'Cap. $num: $title',
        AppLanguage.japanese   => 'Ch. $num: $title', // TODO: native review needed
        AppLanguage.chinese    => 'Ch. $num: $title', // TODO: native review needed
      };

  String chapterNumber(String num) => switch (language) {
        AppLanguage.english    => 'Chapter $num',
        AppLanguage.french     => 'Chapitre $num',
        AppLanguage.spanish    => 'Capítulo $num',
        AppLanguage.italian    => 'Capitolo $num',
        AppLanguage.german     => 'Kapitel $num',
        AppLanguage.portuguese => 'Capítulo $num',
        AppLanguage.japanese   => 'Chapter $num', // TODO: native review needed
        AppLanguage.chinese    => 'Chapter $num', // TODO: native review needed
      };

  String get viaComicK => switch (language) {
        AppLanguage.english    => ' · via ComicK',
        AppLanguage.french     => ' · via ComicK',
        AppLanguage.spanish    => ' · vía ComicK',
        AppLanguage.italian    => ' · via ComicK',
        AppLanguage.german     => ' · über ComicK',
        AppLanguage.portuguese => ' · via ComicK',
        AppLanguage.japanese   => ' · via ComicK', // TODO: native review needed
        AppLanguage.chinese    => ' · via ComicK', // TODO: native review needed
      };

  // ── ChapterReaderScreen ────────────────────────────────────────────────────

  String get failedToLoadChapter => switch (language) {
        AppLanguage.english    => 'Failed to load chapter.',
        AppLanguage.french     => 'Impossible de charger le chapitre.',
        AppLanguage.spanish    => 'Error al cargar el capítulo.',
        AppLanguage.italian    => 'Impossibile caricare il capitolo.',
        AppLanguage.german     => 'Kapitel konnte nicht geladen werden.',
        AppLanguage.portuguese => 'Falha ao carregar o capítulo.',
        AppLanguage.japanese   => 'Failed to load chapter.', // TODO: native review needed
        AppLanguage.chinese    => 'Failed to load chapter.', // TODO: native review needed
      };

  String openIn(String source) => switch (language) {
        AppLanguage.english    => 'Open in $source',
        AppLanguage.french     => 'Ouvrir dans $source',
        AppLanguage.spanish    => 'Abrir en $source',
        AppLanguage.italian    => 'Apri in $source',
        AppLanguage.german     => 'In $source öffnen',
        AppLanguage.portuguese => 'Abrir no $source',
        AppLanguage.japanese   => 'Open in $source', // TODO: native review needed
        AppLanguage.chinese    => 'Open in $source', // TODO: native review needed
      };

  String pagesNotHostedOn(String source) => switch (language) {
        AppLanguage.english    => 'Pages are not hosted on $source for this chapter.',
        AppLanguage.french     => 'Les pages de ce chapitre ne sont pas hébergées sur $source.',
        AppLanguage.spanish    => 'Las páginas no están alojadas en $source para este capítulo.',
        AppLanguage.italian    => 'Le pagine di questo capitolo non sono su $source.',
        AppLanguage.german     => 'Seiten dieses Kapitels werden nicht auf $source gehostet.',
        AppLanguage.portuguese => 'As páginas não estão hospedadas no $source para este capítulo.',
        AppLanguage.japanese   => 'Pages are not hosted on $source for this chapter.', // TODO: native review needed
        AppLanguage.chinese    => 'Pages are not hosted on $source for this chapter.', // TODO: native review needed
      };

  String get chapterHostedExternally => switch (language) {
        AppLanguage.english    => 'This chapter is hosted on an external site.',
        AppLanguage.french     => 'Ce chapitre est hébergé sur un site externe.',
        AppLanguage.spanish    => 'Este capítulo está alojado en un sitio externo.',
        AppLanguage.italian    => 'Questo capitolo è ospitato su un sito esterno.',
        AppLanguage.german     => 'Dieses Kapitel wird auf einer externen Website gehostet.',
        AppLanguage.portuguese => 'Este capítulo está hospedado em um site externo.',
        AppLanguage.japanese   => 'This chapter is hosted on an external site.', // TODO: native review needed
        AppLanguage.chinese    => 'This chapter is hosted on an external site.', // TODO: native review needed
      };

  String get openChapter => switch (language) {
        AppLanguage.english    => 'Open chapter',
        AppLanguage.french     => 'Ouvrir le chapitre',
        AppLanguage.spanish    => 'Abrir capítulo',
        AppLanguage.italian    => 'Apri capitolo',
        AppLanguage.german     => 'Kapitel öffnen',
        AppLanguage.portuguese => 'Abrir capítulo',
        AppLanguage.japanese   => 'Open chapter', // TODO: native review needed
        AppLanguage.chinese    => 'Open chapter', // TODO: native review needed
      };

  String get failedToLoadPage => switch (language) {
        AppLanguage.english    => 'Failed to load page',
        AppLanguage.french     => 'Impossible de charger la page',
        AppLanguage.spanish    => 'Error al cargar la página',
        AppLanguage.italian    => 'Impossibile caricare la pagina',
        AppLanguage.german     => 'Seite konnte nicht geladen werden',
        AppLanguage.portuguese => 'Falha ao carregar a página',
        AppLanguage.japanese   => 'Failed to load page', // TODO: native review needed
        AppLanguage.chinese    => 'Failed to load page', // TODO: native review needed
      };
}
