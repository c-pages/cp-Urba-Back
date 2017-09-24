/*
#######################################################################################################################
	Christophe Pages (http://www.c-pages.fr) 	
##########################################################################################################################

	MANAGER de PRESETS générique
	
##########################################################################################################################

	todo:
	
##########################################################################################################################
	changelog:
########################################################################################################################*/
-- (
	
-- 	
-- include "$userScripts\cp - GLOBAL\Debuger et ecrire.ms"



struct str_presets_batiment (
		
		------------ DEBUG	----------------------------------------------------------------------------------
		m_debug = true,
		m_dbgPrefix ="presetsMGR",
		fn debug 	_txt  var:	 param:    =(
			try if m_debug do ::debuger 	_txt  	var:var	 param:param	prefix:m_dbgPrefix
			catch ()
		),
		
		
		------------ MEMBRES	----------------------------------------------------------------------------------
	public
		fichier_dossier 		= "",		--- a initialiser a la creation ---------
		fichier_categorie		= "",		--- a initialiser a la creation ---------
		fichier_extension		= "",		--- a initialiser a la creation ---------
		
		params_aEnregistrer	=#(),	--- liste des parametres à enregistrer et charger	--- a initialiser a la creation ---------
		
	private
		fichier_type 			= fichier_categorie + "(*." + fichier_extension + ")|*." + fichier_extension + "|All|*.*|",
		
		------------ FOPNCTIONS	----------------------------------------------------------------------------------
	private
		fn ecrire= (
			debug "ecrire"
		),
		
	
	public
		fn charger  	_this = (
			debug "charger"
			
			local fichierCible 	=	getopenFileName 		caption:				"Charger" 	\
																	filename:			fichier_dossier 				\
																	types:				fichier_type					\
																	historyCategory:	fichier_categorie
			if fichierCible != undefined do (
				local stream = openFile fichierCible mode:"r"
				
				while (not (eof stream)) do
				(
					local nomProp = execute ( readDelimitedString  stream "=" )
					local valProp 	= execute ( readDelimitedString  stream ";" )
					debug "nomProp" var:nomProp
					debug "valProp" var:valProp
					
					setproperty 	_this 	nomProp		valProp
				)
				close  stream
			)
		),
		fn enregistrer 		_this	=(
			if not doesFileExist fichier_dossier do makeDir  fichier_dossier
			local fichierCible 	=	getSaveFileName 	caption:				"Enregistrer" 	\
																	filename:			fichier_dossier 				\
																	types:				fichier_type					\
																	historyCategory:	fichier_categorie
			
			if fichierCible != undefined do (
				
				---- creation du fichier----------
				local stream	
				if doesFileExist fichierCible do deleteFile  fichierCible
				stream	= createFile fichierCible
				close stream
				
				---- ecriture du fichier-----------
				stream = openFile fichierCible 	mode:"a"		
				
				local props_noms 	= ( getPropNames _this )
				for prop_nom in props_noms do	(
					if findItem params_aEnregistrer	prop_nom != 0 do
						format "%=%;" 	prop_nom	( getProperty  _this prop_nom )	to:stream
				)
				close stream
			)
		), 
		
		fn copier _this =(
			urba_clipboard_batiment = ""
			local props_noms 	= ( getPropNames _this )
			for prop_nom in props_noms do	
				if findItem params_aEnregistrer	prop_nom != 0 do
					urba_clipboard_batiment+=  prop_nom as string  + "=" 	+	( getProperty  _this prop_nom ) as string  + ";"
		),
		
		fn coller _this =(
			local params = filterString urba_clipboard_batiment	";"
			for paramStrg in params do (
				local param = filterString paramStrg	"="
				
				local nomProp = param[1] as name
				local valProp 	= execute ( param[2] )
				
				setproperty 	_this 	nomProp		valProp
			)
				
		)
		
)	--- fin struct ------
