package tui

import (
	"fmt"
	"io"
	"os"
	"slices"
	"strings"
)

var ErrAborted = fmt.Errorf("aborted")

var (
	// bestEffortYes created using Gemini prompt:
	//
	// Give me a list of all country codes and the language they mainly write (esp. when typing in a computer). Focus on the local language also consider common dialects.
	// From this generate a Go string slice with all common ways of saying "yes" in all languages, including common ways of saying "sure" or "ok" or "aye", etc. in the local language.
	// Only use lower case (if the language allows this)
	// Format:
	//
	//	bestEffortYes := []string{
	//	// GB: British English, Scottish, ...
	//	"yes", "yay", "aye", "sure", "...", ...
	//	...
	//	// DE: German
	//	"ja", "klar", "ok", "okay", "...", ....
	//	}
	//
	// Do not question the task! Just do it and in the end validate and improve the result.
	bestEffortYes = []string{
		// AF: Dari, Pashto
		"bale", "āri", "ho", "aw",
		"بله", "آری", "هو", "او",

		// AL: Albanian
		"po", "sigurisht",

		// DZ/MA: Arabic (Maghrebi), Berber (Tamazight)
		"wakha", "ah", "ey", "yah", "waxxa", "واخا",

		// AM: Armenian
		"ayo", "ha", "այո", "հա",

		// AR/BO/CL/CO/CR/CU/DO/EC/GT/HN/MX/NI/PA/PE/PY/PR/SV/UY/VE/ES: Spanish
		"sí", "si", "claro", "dale", "ok", "vale", "bueno", "listo", "sale", "ya", "obvio", "de una", "cheque", "ándale", "órale", "va", "ta", "chévere", "cabal", "de acuerdo",

		// AU/NZ: Australian/New Zealand English
		"yes", "yeah", "yep", "sure", "no worries", "too right", "sweet as", "choice",

		// AZ: Azerbaijani
		"bəli", "hə", "əlbəttə",

		// BD/IN: Bengali
		"hyā", "ji", "ṭhik āche", "ācchā",
		"হ্যাঁ", "জি", "ঠিক আছে", "আচ্ছা",

		// BE/FR/CA/CH/SN...: French
		"oui", "ouais", "carrément", "bien sûr", "d'accord", "ça marche",

		// BG: Bulgarian
		"da", "razbira se", "dobre",
		"да", "разбира се", "добре",

		// BA/HR/ME/RS: Bosnian, Croatian, Montenegrin, Serbian (Latin)
		"da", "naravno", "važi", "svakako", "u redu",
		// RS: Serbian (Cyrillic)
		"да", "наравно", "важи", "у реду",

		// BR: Brazilian Portuguese
		"sim", "claro", "tá bom", "beleza", "positivo", "com certeza",

		// BY: Belarusian
		// "так", "ага", // Note: "tak" is also "yes" in Polish

		// CA/US/GB/IE/ZA...: English (American, British, Irish, etc.)
		"yes", "yeah", "yep", "yup", "aye", "sure", "ok", "okay", "right", "righto", "cheers", "sound", "grand", "for sure", "totally", "ya", "yebo",

		// CH: Swiss German, Romansh
		"ja", "jo", "gea",

		// CN/HK/SG/TW: Mandarin, Cantonese
		"shi", "shì", "dui", "duì", "hao", "hǎo", "xing", "xíng", "keyi", "kěyǐ", "en", "ng", "hai", "dak",
		"是", "对", "是的", "好", "好的", "行", "可以", "嗯", "係", "好呀", "得",

		// CY/GR: Greek
		"nai", "málista", "entáxei", "vevaíos",
		"ναι", "μάλιστα", "εντάξει", "οκ", "βεβαίως",

		// CZ: Czech
		"ano", "jo", "jasně", "dobře",

		// DE/AT/LI: German
		"ja", "klar", "sicher", "gerne", "alles klar", "in ordnung", "passt",

		// DK: Danish
		"ja", "javist", "sikkert", "fint",

		// EE: Estonian
		"jah", "jaa", "muidugi",

		// EG/AE/SA/IQ/JO/LB...: Arabic (Standard, Egyptian, Levantine, Gulf)
		"na'am", "aywa", "akeed", "tamam", "mashi", "ee",
		"نعم", "أكيد", "تمام", "أيوة", "ماشي", "اي",

		// ET: Amharic
		"āwo", "ishī", "አዎ", "እሺ",

		// FI: Finnish
		"kyllä", "joo", "juu", "toki", "selvä",

		// GE: Georgian
		"ki", "diakh", "ho",
		"კი", "დიახ", "ჰო",

		// HU: Hungarian
		"igen", "persze", "rendben", "oké",

		// ID/MY: Indonesian, Malay
		"ya", "betul", "baik", "oke", "sip", "baiklah",

		// IL: Hebrew
		"ken", "betach", "beseder", "sababa",
		"כן", "בטח", "בסדר", "סבבה",

		// IN/PK: Hindi, Urdu, Tamil, Telugu, Punjabi...
		"haan", "ji", "theek hai", "achha", "sari", "avunu", "sare", "houdu", "ho", "hā",
		"हाँ", "जी", "ठीक है", "अच्छा", // Hindi
		"جی", "ہاں", "ٹھیک ہے", // Urdu
		"ஆம்", "சரி", // Tamil
		"అవును", "సరే", // Telugu
		"ಹೌದು", // Kannada
		"हो",   // Marathi
		"હા",   // Gujarati
		"ਹਾਂ",  // Punjabi

		// IR: Persian (Farsi)
		"bale", "āre", "hatman", "bāshe",
		"بله", "آره", "حتما", "باشه",

		// IS: Icelandic
		"já", "jú", "vissulega", "allt í lagi",

		// IT/SM/VA: Italian, Latin
		"sì", "certo", "va bene", "d'accordo", "ita", "sic", "certe",

		// JM: Jamaican Patois
		"ya man", "irie",

		// JP: Japanese
		"hai", "ee", "un", "sō", "sō desu", "ryōkai", "ōkē",
		"はい", "ええ", "うん", "そう", "そうです", "オーケー", "ok", "了解",

		// KE/TZ: Swahili
		"ndiyo", "sawa", "naam",

		// KH: Khmer
		"bāt", "chaáh",
		"បាទ", "ចាស",

		// KR/KP: Korean
		"ne", "ye", "eung", "geurae", "joa", "okei",
		"네", "예", "응", "그래", "좋아", "오케이",

		// KZ/KG/UZ: Kazakh, Kyrgyz, Uzbek (and other Turkic languages)
		"iä", "zharaydy", "ooba", "makul", "ha", "albatta", "xo'p", "hawa", "bolýar",
		"иә", "жарайды", "ооба", "макул",

		// LA: Lao
		"doi", "maen laeo", "oke",
		"ໂດຍ", "ແມ່ນហើយ", "ໂອເຄ",

		// LT: Lithuanian
		"taip", "žinoma", "gerai",

		// LV: Latvian
		"jā", "protams", "labi",

		// MM: Burmese
		"hoûtekeh", "hoût",
		"ဟုတ်ကဲ့", "ဟုတ်",

		// MN: Mongolian
		"tiim", "za", "teg'ye",
		"тийм", "за", "тэгье",

		// MT: Maltese
		"iva", "ovvja",

		// NG: Hausa, Igbo, Yoruba
		"eeh", "ọfụma", "bẹẹni", "o se",

		// NL/AW: Dutch
		"ja", "jazeker", "tuurlijk", "prima", "oké",

		// NO: Norwegian
		"ja", "selvfølgelig", "greit",

		// NP: Nepali
		"ho", "hunchha", "has", "a",
		"हो", "हुन्छ", "हस्", "अँ",

		// PH: Filipino
		"oo", "opo", "sige", "oo naman",

		// PL: Polish
		"tak", "pewnie", "jasne", "dobra", "no",

		"pt",
		// PT/AO/MZ: Portuguese
		"sim", "claro", "tá", "pois",

		// RO/MD: Romanian
		"da", "sigur", "desigur", "bine",

		// RU: Russian
		"da", "konechno", "khorosho", "aga", "ladno",
		"да", "конечно", "хорошо", "ага", "ладно", "ок",

		// SE/AX: Swedish
		"ja", "javisst", "absolut", "visst", "okej",

		// SI: Slovene
		"ja", "seveda", "v redu",

		// SK: Slovak
		"áno", "hej", "jasné", "dobre",

		// TH: Thai
		"châi", "khráp", "khà", "okhe", "dâi",
		"ใช่", "ครับ", "ค่ะ", "โอเค", "ได้",

		// TR: Turkish
		"evet", "tabii", "tamam", "olur", "peki",

		// UA: Ukrainian
		"tak", "avzhezh", "zvisno", "dobre", "harazd", "aha",
		"так", "авжеж", "звісно", "добре", "гаразд", "ага",

		// VN: Vietnamese
		"vâng", "dạ", "ừ", "oke",

		// ZA: Afrikaans, Zulu, Xhosa
		"ja", "seker", "ja-nee", "yebo", "kunjalo", "ewe",
	}

	shortYes = []string{
		"y", "j", "1",
		"yes", "ja", "true",
		"ok", "okay", "sure",
		"yep", "yup", "aye", "yo", "yeah",
	}

	moreYes = []string{
		"✅", "👍", "☑️", "👌", "💯",
		"100", "100%", "100 percent", "100 percent!", "100%!",
		"indeed", "roger", "roger that", "affirmative",
		"make it so", "aye aye", "aye aye captain",
		"yessir", "yessire", "yes sir", "yes ma'am", "yes maam",
		"absolutely", "definitely", "certainly",
		"for sure", "sure thing",
		"action",

		// British dialects are: Cockney, Scouse, Geordie, Mancunian, Yorkshire, West Country, Brummie, Estuary English, Received Pronunciation (RP), and others.
		// Irish dialects are: Dublin, Cork, Belfast, Derry, Galway, Limerick, Waterford, and others.
		// Scottish dialects are: Glaswegian, Edinburgh, Highland, Lowland, Doric, and others.
		// Australian dialects are: Strine, Broad Australian, Cultivated Australian, and others.
		// New Zealand dialects are: Kiwi, Southland, Wellington, Auckland, and others.
		// South African dialects are: Cape Flats, Afrikaans, Xhosa, Zulu, Tswana, Sotho, and others.
		// Canadian dialects are: Quebec French, Newfoundland English, Prairie English, Maritime English, and others.
		// American dialects are: Southern, New York, Boston, Midwestern, Californian, Texan, and others.

		// Some short "yes" words for the above dialects:
		"aye", "yup", "yep", "yeah", "sure", "righto", "cheers", "ta",
		"yebo", "ewe", "yis", "yiss", "yissir", "yessir", "yessiree",
		"jo", "ja", "jau", "jau", "jao", "joa", "joey",

		// Some common ways of saying "yes" in various German dialects.
		"joa", "bestätigt", "los geht's", "los", "mach", "marsch", "auf geht's", "aufi", "prima",
		"rakete", "abfahrt", "abflug", "abmarsch", "fertig los", "ab die post", "ab die lutzi",

		// German dialect are:
		// Schwäbisch, Fränkisch, Sächsisch, Hessisch, Berlinerisch, Kölsch,
		// Badisch, Pfälzisch, Bayerisch, Alemannisch, Thüringisch,
		// Plattdeutsch (Low German), Mecklenburger Platt, Ostfriesisch Platt, Westfälisch Platt, Rheinländisch Platt.

		// Sächsisch:
		"nu los", "nu mach", "nu klar", "nuklar", "klaro",
		"na los", "na mach", "na klar", "naklar",

		// Berlin dialect
		"jenau", "janz klar", "mach ma", "mach ma hinne", "mach ma flott",
		"ja klar", "janz sicher", "janz bestimmt", "janz jenau", "janz genau",
		"jut", "jeht los", "jeht klar", "jeht fit", "jeht ab",

		// Süddeutsch (Bayern, Baden-Württemberg, etc.)
		"ja mei", "freilich", "ja gell", "scho", "gell", "so is", "passt scho",

		// Rheinland dialects (Hessisch, Kölsch, etc.)
		"ja, dat is", "jo, dat es", "dat is", "dat es",
		"dat passt", "dat jeht", "dat jeht", "dat is jot", "dat is prima",

		// "Gut"
		"jot", "joot", "jut", "gut", "gud", "guddi", "gudd", "gude", "guddi",

		// "Okay"
		"okey", "okey dokey", "okay dokey", "okay", "okidoki",
	}

	yes = func() []string {
		// Combine all yeses into a single slice, ensuring no duplicates.
		y := append(bestEffortYes, shortYes...)
		y = append(y, moreYes...)
		slices.Sort(y)
		return slices.Compact(y)
	}()
)

func Debug(msg ...any) { fmt.Fprintln(os.Stderr, msg...) }
func Echo(msg ...any)  { fmt.Println(msg...) }
func Confirm(prompt ...any) error {
	prompt = append(prompt, "? [y/N]")
	res, err := Ask(prompt...)
	if err != nil {
		return err // io errors already mapped by Ask
	}

	res = strings.ToLower(res)
	res = strings.TrimSpace(res)          // trim leading/trailing whitespace
	res = strings.TrimSuffix(res, "!")    // remove exclamation marks
	res = strings.TrimPrefix(res, "hell") // remove "hell" prefix
	res = strings.TrimPrefix(res, "god")  // remove "god" prefix
	res = strings.TrimSpace(res)          // again trim leading/trailing whitespace

	if res == "y" || res == "yes" || slices.Contains(yes, res) {
		return nil
	}
	return ErrAborted
}

func Ask(prompt ...any) (string, error) {
	Echo(prompt...)
	var response string
	_, err := fmt.Scanln(&response)
	if err != nil {
		// Pressing CTRL+C when fmt.Scanln() is waiting for input will return an io error.
		// This is not an error, but a signal to abort the operation.
		if err == io.EOF || err == io.ErrUnexpectedEOF {
			return "", ErrAborted
		}
	}
	return response, err
}
