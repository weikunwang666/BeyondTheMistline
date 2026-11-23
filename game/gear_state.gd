extends RefCounted

const OUTFITS=["防雨外套","加固背心"]
var worn=""

func insulation() -> float:
 return 1.0 if worn=="防雨外套" else (0.25 if worn=="加固背心" else 0.0)

func rain_exposure() -> float:
 return 0.25 if worn=="防雨外套" else 1.0

func damage_multiplier() -> float:
 return 0.75 if worn=="加固背心" else 1.0

func reconcile(inventory: Dictionary):
 if worn!="" and inventory.get(worn,0)<=0: worn=""

func restore(value,inventory: Dictionary):
 worn=value if value is String and value in OUTFITS else ""
 reconcile(inventory)
