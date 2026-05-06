# TICKETSPP

## Normalización de labels legacy

Para migrar labels legacy (`digifort`, `hikvision`, `ccure`) a labels canónicas (`sistema:*`) y luego consolidar nombre/color/descripción final, ejecutar:

```bash
scripts/normalize_legacy_labels.sh
```

Opcionalmente se puede indicar otro repositorio:

```bash
scripts/normalize_legacy_labels.sh owner/repo
```

Este script:
1. inventaria labels actuales,
2. renombra o migra y elimina labels legacy,
3. valida que no queden issues abiertos con labels legacy,
4. ejecuta `scripts/sync_labels.sh`.
