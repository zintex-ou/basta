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

def catalog(d):
    strings = {}
    for key, (en, es, it) in d.items():
        strings[key] = {"localizations": {
            "en": {"stringUnit": {"state": "translated", "value": en}},
            "es": {"stringUnit": {"state": "translated", "value": es}},
            "it": {"stringUnit": {"state": "translated", "value": it}},
        }}
    return {"sourceLanguage": "en", "version": "1.0", "strings": strings}

json.dump(catalog(APP), open("Basta/Localizable.xcstrings", "w"), ensure_ascii=False, indent=2)
json.dump(catalog(SHIELD), open("BastaShield/Localizable.xcstrings", "w"), ensure_ascii=False, indent=2)
json.dump(catalog({"report.today": APP["report.today"]}), open("BastaReport/Localizable.xcstrings", "w"), ensure_ascii=False, indent=2)
print(len(APP), "app strings,", len(SHIELD), "shield strings")
