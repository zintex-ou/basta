#!/usr/bin/env python3
"""Builds Localizable.xcstrings (en/es/it) for the app and the shield extension."""
import json, sys

APP = {
    # onboarding
    "onb.next": ("Continue", "Continuar", "Continua"),
    "onb.finish": ("Start", "Empezar", "Inizia"),
    "onb.hook.title": ("Enough scrolling.", "Basta de scroll.", "Basta scrollare."),
    "onb.hook.body": ("You lose hours a day to apps you didn't even mean to open. Basta blocks them when you need focus — and gives you your time back.",
                      "Pierdes horas al día en apps que ni querías abrir. Basta las bloquea cuando necesitas concentrarte y te devuelve tu tiempo.",
                      "Perdi ore al giorno in app che non volevi nemmeno aprire. Basta le blocca quando ti serve concentrazione e ti restituisce il tuo tempo."),
    "onb.how.title": ("How it works", "Cómo funciona", "Come funziona"),
    "onb.how.schedule": ("Block apps on a schedule — work, sleep, study.", "Bloquea apps por horario: trabajo, sueño, estudio.", "Blocca le app a orari: lavoro, sonno, studio."),
    "onb.how.place": ("Block apps automatically when you arrive somewhere.", "Bloquea apps automáticamente al llegar a un lugar.", "Blocca le app automaticamente quando arrivi in un luogo."),
    "onb.how.strict": ("Strict mode: no way out until the session ends.", "Modo estricto: sin salida hasta que termine la sesión.", "Modalità rigida: nessuna via d'uscita fino alla fine."),
    "onb.how.quick": ("One tap for 15, 30 or 60 minutes of focus.", "Un toque para 15, 30 o 60 minutos de foco.", "Un tocco per 15, 30 o 60 minuti di concentrazione."),
    "onb.perm.title": ("Allow Screen Time", "Permite Tiempo de uso", "Consenti Tempo di utilizzo"),
    "onb.perm.body": ("Basta uses Apple's Screen Time to block the apps you choose. Nothing else.", "Basta usa Tiempo de uso de Apple para bloquear las apps que elijas. Nada más.", "Basta usa Tempo di utilizzo di Apple per bloccare le app che scegli. Nient'altro."),
    "onb.perm.privacy": ("Everything stays on your iPhone. We never see which apps you use.", "Todo se queda en tu iPhone. Nunca vemos qué apps usas.", "Tutto resta sul tuo iPhone. Non vediamo mai quali app usi."),
    "onb.perm.cta": ("Allow", "Permitir", "Consenti"),
    "onb.apps.title": ("What distracts you?", "¿Qué te distrae?", "Cosa ti distrae?"),
    "onb.apps.body": ("Pick the apps that eat your time. You can change this anytime.", "Elige las apps que te roban tiempo. Puedes cambiarlo cuando quieras.", "Scegli le app che ti rubano tempo. Puoi cambiarle quando vuoi."),
    "onb.apps.pick": ("Choose apps", "Elegir apps", "Scegli le app"),
    "onb.apps.picked %lld": ("%lld selected", "%lld seleccionadas", "%lld selezionate"),
    "mode.default.name": ("Focus", "Foco", "Focus"),
    # paywall
    "pw.title": ("Take your time back", "Recupera tu tiempo", "Riprenditi il tuo tempo"),
    "pw.subtitle": ("Basta members cut their screen time by half in the first week.", "Los miembros de Basta reducen su tiempo de pantalla a la mitad en la primera semana.", "Chi usa Basta dimezza il tempo di schermo nella prima settimana."),
    "pw.b1": ("Unlimited focus modes", "Modos de foco ilimitados", "Modalità focus illimitate"),
    "pw.b2": ("Schedules and location triggers", "Horarios y activación por ubicación", "Orari e attivazione per luogo"),
    "pw.b3": ("Strict mode you can't bypass", "Modo estricto sin trampas", "Modalità rigida senza scappatoie"),
    "pw.b4": ("Daily screen time report", "Informe diario de tiempo de pantalla", "Report giornaliero del tempo di schermo"),
    "pw.yearly": ("Yearly", "Anual", "Annuale"),
    "pw.weekly": ("Weekly", "Semanal", "Settimanale"),
    "pw.best": ("BEST VALUE", "MEJOR PRECIO", "PIÙ CONVENIENTE"),
    "pw.perWeek": ("/ week", "/ semana", "/ settimana"),
    "pw.perMonth": ("/ month", "/ mes", "/ mese"),
    "pw.perYear": ("/ year", "/ año", "/ anno"),
    "pw.cta": ("Continue", "Continuar", "Continua"),
    "pw.restore": ("Restore", "Restaurar", "Ripristina"),
    "pw.terms": ("Terms", "Términos", "Termini"),
    "pw.privacy": ("Privacy", "Privacidad", "Privacy"),
    "pw.legal": ("Subscription renews automatically unless cancelled at least 24 hours before the end of the period. Manage in App Store settings.",
                 "La suscripción se renueva automáticamente salvo que se cancele al menos 24 horas antes del fin del periodo. Gestiónala en los ajustes del App Store.",
                 "L'abbonamento si rinnova automaticamente salvo disdetta almeno 24 ore prima della fine del periodo. Gestiscilo nelle impostazioni dell'App Store."),
    # home
    "home.newMode": ("New mode", "Nuevo modo", "Nuova modalità"),
    "home.status.on": ("Blocking is on", "Bloqueo activo", "Blocco attivo"),
    "home.status.off": ("Nothing blocked", "Nada bloqueado", "Niente bloccato"),
    "home.status.onHint": ("Your distracting apps are locked.", "Tus apps distractoras están bloqueadas.", "Le tue app distraenti sono bloccate."),
    "home.status.offHint": ("Turn on a mode or tap and hold for a quick session.", "Activa un modo o mantén pulsado para una sesión rápida.", "Attiva una modalità o tieni premuto per una sessione rapida."),
    "home.status.strictUntil %@": ("Strict until %@", "Estricto hasta las %@", "Rigido fino alle %@"),
    "home.quick.title": ("Quick focus", "Foco rápido", "Focus rapido"),
    "home.quick.menu": ("Quick focus…", "Foco rápido…", "Focus rapido…"),
    "home.quick.minutes %lld": ("%lld minutes", "%lld minutos", "%lld minuti"),
    "home.edit": ("Edit", "Editar", "Modifica"),
    "mode.manual": ("Manual", "Manual", "Manuale"),
    "mode.strict.short": ("Strict", "Estricto", "Rigido"),
    # editor
    "editor.new": ("New mode", "Nuevo modo", "Nuova modalità"),
    "editor.edit": ("Edit mode", "Editar modo", "Modifica modalità"),
    "editor.name": ("Name", "Nombre", "Nome"),
    "editor.apps": ("Blocked apps", "Apps bloqueadas", "App bloccate"),
    "editor.apps.pick": ("Choose apps and websites", "Elegir apps y webs", "Scegli app e siti"),
    "editor.apps.count %lld": ("%lld selected", "%lld seleccionadas", "%lld selezionate"),
    "editor.schedule": ("Schedule", "Horario", "Orario"),
    "editor.schedule.on": ("Repeat weekly", "Repetir cada semana", "Ripeti ogni settimana"),
    "editor.from": ("From", "Desde", "Dalle"),
    "editor.to": ("To", "Hasta", "Alle"),
    "editor.place": ("Place", "Lugar", "Luogo"),
    "editor.place.on": ("Turn on when I arrive", "Activar al llegar", "Attiva quando arrivo"),
    "editor.place.pick": ("Choose a place", "Elegir lugar", "Scegli un luogo"),
    "editor.strict": ("Strict mode", "Modo estricto", "Modalità rigida"),
    "editor.strict.footer": ("You won't be able to turn this mode off until its session ends.", "No podrás desactivar este modo hasta que termine la sesión.", "Non potrai disattivare questa modalità finché la sessione non finisce."),
    "editor.delete": ("Delete mode", "Eliminar modo", "Elimina modalità"),
    "editor.cancel": ("Cancel", "Cancelar", "Annulla"),
    "editor.save": ("Save", "Guardar", "Salva"),
    "place.title": ("Place", "Lugar", "Luogo"),
    "place.name": ("Name (e.g. Office, Library)", "Nombre (p. ej. Oficina, Biblioteca)", "Nome (es. Ufficio, Biblioteca)"),
    "place.hint": ("Move the map so the pin is on the place.", "Mueve el mapa para que el pin quede sobre el lugar.", "Sposta la mappa finché il pin è sul luogo."),
    "place.default": ("My place", "Mi lugar", "Il mio luogo"),
    # settings
    "settings.title": ("Settings", "Ajustes", "Impostazioni"),
    "settings.done": ("Done", "Listo", "Fine"),
    "settings.report": ("Today", "Hoy", "Oggi"),
    "settings.permissions": ("Permissions", "Permisos", "Permessi"),
    "settings.location": ("Location", "Ubicación", "Posizione"),
    "settings.location.always": ("Always", "Siempre", "Sempre"),
    "settings.location.inUse": ("While using", "Al usar la app", "Mentre usi l'app"),
    "settings.location.denied": ("Denied", "Denegado", "Negato"),
    "settings.location.none": ("Not set", "Sin configurar", "Non impostato"),
    "settings.openSettings": ("Open iPhone Settings", "Abrir Ajustes del iPhone", "Apri Impostazioni iPhone"),
    "settings.subscription": ("Subscription", "Suscripción", "Abbonamento"),
    "settings.manage": ("Manage subscription", "Gestionar suscripción", "Gestisci abbonamento"),
    "settings.support": ("Contact support", "Contactar soporte", "Contatta il supporto"),
    "report.today": ("screen time today", "de pantalla hoy", "di schermo oggi"),
}

SHIELD = {
    "shield.title": ("Basta.", "Basta.", "Basta."),
    "shield.subtitle": ("This app is blocked right now. You chose this.", "Esta app está bloqueada ahora. Tú lo decidiste.", "Questa app è bloccata adesso. L'hai deciso tu."),
    "shield.subtitle.strict": ("Strict mode is on. No way out until the session ends.", "Modo estricto activo. Sin salida hasta que termine la sesión.", "Modalità rigida attiva. Nessuna via d'uscita fino alla fine."),
    "shield.ok": ("OK", "Vale", "Ok"),
}

DE = {'onb.next': 'Weiter', 'onb.finish': "Los geht's", 'onb.hook.title': 'Schluss mit Scrollen.', 'onb.hook.body': 'Du verlierst täglich Stunden an Apps, die du nicht mal öffnen wolltest. Basta sperrt sie, wenn du Fokus brauchst – und gibt dir deine Zeit zurück.', 'onb.how.title': "So funktioniert's", 'onb.how.schedule': 'Apps nach Zeitplan sperren – Arbeit, Schlaf, Lernen.', 'onb.how.place': 'Apps automatisch sperren, wenn du irgendwo ankommst.', 'onb.how.strict': 'Strenger Modus: kein Ausweg, bis die Session endet.', 'onb.how.quick': 'Ein Tipp für 15, 30 oder 60 Minuten Fokus.', 'onb.perm.title': 'Bildschirmzeit erlauben', 'onb.perm.body': 'Basta nutzt Apples Bildschirmzeit, um die Apps zu sperren, die du wählst. Sonst nichts.', 'onb.perm.privacy': 'Alles bleibt auf deinem iPhone. Wir sehen nie, welche Apps du nutzt.', 'onb.perm.cta': 'Erlauben', 'onb.apps.title': 'Was lenkt dich ab?', 'onb.apps.body': 'Wähle die Apps, die deine Zeit fressen. Du kannst das jederzeit ändern.', 'onb.apps.pick': 'Apps wählen', 'onb.apps.picked %lld': '%lld ausgewählt', 'mode.default.name': 'Fokus', 'pw.title': 'Hol dir deine Zeit zurück', 'pw.subtitle': 'Basta-Nutzer halbieren ihre Bildschirmzeit in der ersten Woche.', 'pw.b1': 'Unbegrenzte Fokus-Modi', 'pw.b2': 'Zeitpläne und Orts-Auslöser', 'pw.b3': 'Strenger Modus ohne Schlupflöcher', 'pw.b4': 'Täglicher Bildschirmzeit-Bericht', 'pw.yearly': 'Jährlich', 'pw.weekly': 'Wöchentlich', 'pw.best': 'BESTER PREIS', 'pw.perWeek': '/ Woche', 'pw.perMonth': '/ Monat', 'pw.perYear': '/ Jahr', 'pw.cta': 'Weiter', 'pw.restore': 'Wiederherstellen', 'pw.terms': 'AGB', 'pw.privacy': 'Datenschutz', 'pw.legal': 'Das Abo verlängert sich automatisch, sofern es nicht mindestens 24 Stunden vor Ende des Zeitraums gekündigt wird. Verwaltung in den App Store-Einstellungen.', 'home.newMode': 'Neuer Modus', 'home.status.on': 'Sperre aktiv', 'home.status.off': 'Nichts gesperrt', 'home.status.onHint': 'Deine Ablenkungs-Apps sind gesperrt.', 'home.status.offHint': 'Aktiviere einen Modus oder halte gedrückt für eine Schnell-Session.', 'home.status.strictUntil %@': 'Streng bis %@', 'home.quick.title': 'Schnell-Fokus', 'home.quick.menu': 'Schnell-Fokus …', 'home.quick.minutes %lld': '%lld Minuten', 'home.edit': 'Bearbeiten', 'mode.manual': 'Manuell', 'mode.strict.short': 'Streng', 'editor.new': 'Neuer Modus', 'editor.edit': 'Modus bearbeiten', 'editor.name': 'Name', 'editor.apps': 'Gesperrte Apps', 'editor.apps.pick': 'Apps und Websites wählen', 'editor.apps.count %lld': '%lld ausgewählt', 'editor.schedule': 'Zeitplan', 'editor.schedule.on': 'Wöchentlich wiederholen', 'editor.from': 'Von', 'editor.to': 'Bis', 'editor.place': 'Ort', 'editor.place.on': 'Bei Ankunft aktivieren', 'editor.place.pick': 'Ort wählen', 'editor.strict': 'Strenger Modus', 'editor.strict.footer': 'Du kannst diesen Modus erst ausschalten, wenn die Session vorbei ist.', 'editor.delete': 'Modus löschen', 'editor.cancel': 'Abbrechen', 'editor.save': 'Sichern', 'place.title': 'Ort', 'place.name': 'Name (z. B. Büro, Bibliothek)', 'place.hint': 'Verschiebe die Karte, bis der Pin auf dem Ort liegt.', 'place.default': 'Mein Ort', 'settings.title': 'Einstellungen', 'settings.done': 'Fertig', 'settings.report': 'Heute', 'settings.permissions': 'Berechtigungen', 'settings.location': 'Standort', 'settings.location.always': 'Immer', 'settings.location.inUse': 'Beim Verwenden', 'settings.location.denied': 'Abgelehnt', 'settings.location.none': 'Nicht festgelegt', 'settings.openSettings': 'iPhone-Einstellungen öffnen', 'settings.subscription': 'Abo', 'settings.manage': 'Abo verwalten', 'settings.support': 'Support kontaktieren', 'report.today': 'Bildschirmzeit heute', 'shield.title': 'Basta.', 'shield.subtitle': 'Diese App ist gerade gesperrt. Du hast es so entschieden.', 'shield.subtitle.strict': 'Strenger Modus aktiv. Kein Ausweg, bis die Session endet.', 'shield.ok': 'OK'}

FR = {'onb.next': 'Continuer', 'onb.finish': 'Commencer', 'onb.hook.title': 'Stop au scroll.', 'onb.hook.body': 'Tu perds des heures chaque jour dans des apps que tu ne voulais même pas ouvrir. Basta les bloque quand tu as besoin de te concentrer – et te rend ton temps.', 'onb.how.title': 'Comment ça marche', 'onb.how.schedule': 'Bloque des apps selon un horaire – travail, sommeil, études.', 'onb.how.place': 'Bloque des apps automatiquement quand tu arrives quelque part.', 'onb.how.strict': "Mode strict : impossible d'en sortir avant la fin de la session.", 'onb.how.quick': 'Un toucher pour 15, 30 ou 60 minutes de concentration.', 'onb.perm.title': "Autoriser Temps d'écran", 'onb.perm.body': "Basta utilise Temps d'écran d'Apple pour bloquer les apps que tu choisis. Rien d'autre.", 'onb.perm.privacy': 'Tout reste sur ton iPhone. Nous ne voyons jamais quelles apps tu utilises.', 'onb.perm.cta': 'Autoriser', 'onb.apps.title': "Qu'est-ce qui te distrait ?", 'onb.apps.body': 'Choisis les apps qui te volent du temps. Tu peux changer ça à tout moment.', 'onb.apps.pick': 'Choisir des apps', 'onb.apps.picked %lld': '%lld sélectionnées', 'mode.default.name': 'Focus', 'pw.title': 'Reprends ton temps', 'pw.subtitle': "Les membres Basta divisent leur temps d'écran par deux dès la première semaine.", 'pw.b1': 'Modes focus illimités', 'pw.b2': 'Horaires et déclenchement par lieu', 'pw.b3': 'Mode strict sans échappatoire', 'pw.b4': "Rapport quotidien de temps d'écran", 'pw.yearly': 'Annuel', 'pw.weekly': 'Hebdomadaire', 'pw.best': 'MEILLEUR PRIX', 'pw.perWeek': '/ semaine', 'pw.perMonth': '/ mois', 'pw.perYear': '/ an', 'pw.cta': 'Continuer', 'pw.restore': 'Restaurer', 'pw.terms': 'Conditions', 'pw.privacy': 'Confidentialité', 'pw.legal': "L'abonnement se renouvelle automatiquement sauf résiliation au moins 24 heures avant la fin de la période. Gère-le dans les réglages de l'App Store.", 'home.newMode': 'Nouveau mode', 'home.status.on': 'Blocage actif', 'home.status.off': 'Rien de bloqué', 'home.status.onHint': 'Tes apps distrayantes sont bloquées.', 'home.status.offHint': 'Active un mode ou maintiens appuyé pour une session rapide.', 'home.status.strictUntil %@': "Strict jusqu'à %@", 'home.quick.title': 'Focus rapide', 'home.quick.menu': 'Focus rapide…', 'home.quick.minutes %lld': '%lld minutes', 'home.edit': 'Modifier', 'mode.manual': 'Manuel', 'mode.strict.short': 'Strict', 'editor.new': 'Nouveau mode', 'editor.edit': 'Modifier le mode', 'editor.name': 'Nom', 'editor.apps': 'Apps bloquées', 'editor.apps.pick': 'Choisir apps et sites', 'editor.apps.count %lld': '%lld sélectionnées', 'editor.schedule': 'Horaire', 'editor.schedule.on': 'Répéter chaque semaine', 'editor.from': 'De', 'editor.to': 'À', 'editor.place': 'Lieu', 'editor.place.on': 'Activer à mon arrivée', 'editor.place.pick': 'Choisir un lieu', 'editor.strict': 'Mode strict', 'editor.strict.footer': 'Tu ne pourras pas désactiver ce mode avant la fin de la session.', 'editor.delete': 'Supprimer le mode', 'editor.cancel': 'Annuler', 'editor.save': 'Enregistrer', 'place.title': 'Lieu', 'place.name': 'Nom (ex. Bureau, Bibliothèque)', 'place.hint': "Déplace la carte pour placer l'épingle sur le lieu.", 'place.default': 'Mon lieu', 'settings.title': 'Réglages', 'settings.done': 'OK', 'settings.report': "Aujourd'hui", 'settings.permissions': 'Autorisations', 'settings.location': 'Position', 'settings.location.always': 'Toujours', 'settings.location.inUse': "Pendant l'utilisation", 'settings.location.denied': 'Refusée', 'settings.location.none': 'Non définie', 'settings.openSettings': "Ouvrir les Réglages de l'iPhone", 'settings.subscription': 'Abonnement', 'settings.manage': "Gérer l'abonnement", 'settings.support': 'Contacter le support', 'report.today': "de temps d'écran aujourd'hui", 'shield.title': 'Basta.', 'shield.subtitle': "Cette app est bloquée pour l'instant. C'est toi qui l'as décidé.", 'shield.subtitle.strict': "Mode strict actif. Impossible d'en sortir avant la fin de la session.", 'shield.ok': 'OK'}

def catalog(d):
    strings = {}
    for key, (en, es, it) in d.items():
        strings[key] = {"localizations": {
            "en": {"stringUnit": {"state": "translated", "value": en}},
            "es": {"stringUnit": {"state": "translated", "value": es}},
            "it": {"stringUnit": {"state": "translated", "value": it}},
            "de": {"stringUnit": {"state": "translated", "value": DE[key]}},
            "fr": {"stringUnit": {"state": "translated", "value": FR[key]}},
        }}
    return {"sourceLanguage": "en", "version": "1.0", "strings": strings}

json.dump(catalog(APP), open("Basta/Localizable.xcstrings", "w"), ensure_ascii=False, indent=2)
json.dump(catalog(SHIELD), open("BastaShield/Localizable.xcstrings", "w"), ensure_ascii=False, indent=2)
json.dump(catalog({"report.today": APP["report.today"]}), open("BastaReport/Localizable.xcstrings", "w"), ensure_ascii=False, indent=2)
print(len(APP), "app strings,", len(SHIELD), "shield strings")
