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
		fichier_categorie	= "",		--- a initialiser a la creation ---------
		fichier_extension	= "",		--- a initialiser a la creation ---------
		
		params_aEnregistrer	=#(),	--- liste des parametres à enregistrer et charger	--- a initialiser a la creation ---------
		
	private
		fichier_type 			= fichier_categorie + "(*." + fichier_extension + ")|*." + fichier_extension + "|All|*.*|",
		
		separateur_params ="¤",
		separateur_mutation = "=",
		separateur_items = ";",
		
		------------ FOPNCTIONS	----------------------------------------------------------------------------------
	public
		fn ecrire	= (
			debug "ecrire"
		),
		fn lire_datas 	_fichier = (
			debug "lire_datas"
			local stream = openFile _fichier mode:"r"
			local datas = readLine  stream
			debug "datas" var:datas
			/* 
			while (not (eof stream)) do
			(
				local nomProp 	= execute ( readDelimitedString  stream "=" )
				local valProp 	= execute ( readDelimitedString  stream ";" )
-- 					debug "nomProp" var:nomProp
-- 					debug "valProp" var:valProp
				
				setproperty 	_this 	nomProp		valProp
			) */
			close  stream
			datas
		),
		fn get_datas 			_this =(
			debug "get_datas"
			local txtResult = ""
			for param in params_aEnregistrer do (
				local prop = ( getProperty  _this 	param )
				local type = classof prop
			debug "param" var:param
			debug "type" var:type
			debug "prop" var:prop
				case type of (
					MAXScriptFunction:	()
					string:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
					ArrayParameter: (
						local tabString = ""
						for item in prop do
							tabString += item + separateur_items
						debug "tabString" var:tabString
						txtResult+=  param as string  + separateur_mutation 	+	tabString  + separateur_params
					)
					default:						(
						txtResult+=  param as string  + separateur_mutation	+	prop as string  + separateur_params
					)
				)
			)
			txtResult
		),
		fn set_Params 		_this		_datas =(
			debug "set_Params"
			debug "_datas" var:_datas
			
			local params = filterString _datas		separateur_params
			for paramStrg in params do (
				local param = filterString paramStrg		separateur_mutation
				
				local nomProp = param[1] as name
				local prop = ( getProperty  _this 	nomProp )
				local type = classof prop
				debug "nomProp" var:nomProp
				debug "type" var:type
				case type of (
					string:						( setproperty 	_this 	nomProp	param[2]
					)
					ArrayParameter: (
						local paramTab = filterString 	param[2]		separateur_items
						
						debug "param[2]" var:param[2]
						debug "paramTab" var:paramTab
						setproperty 	_this 	nomProp	paramTab
						
					)
					MAXScriptFunction:	()
					default:						(setproperty 	_this 	nomProp	(execute param[2])
					)
				)
			)
		),
	public
		fn charger  	_this 	= (
			debug "charger"
			
			local fichierCible 	=	getopenFileName 		caption:				"Charger" 				\
																			filename:				fichier_dossier 		\
																			types:					fichier_type			\
																			historyCategory:	fichier_categorie
			if fichierCible != undefined do (
				local datas = lire_datas 	fichierCible
				set_Params 	_this 	datas
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
				local txt = get_datas		_this 
				format "%" 	txt 					to:stream
				close stream
			)
		), 
		
		fn copier _this =(
			urba_clipboard_batiment = get_datas		_this 
			/* 
			for param in params_aEnregistrer do (
				local prop = ( getProperty  _this 	param )
				local type = classof prop
				case type of (
					MAXScriptFunction:	()
					string:						(
						urba_clipboard_batiment+=  param as string  + separateur_mutation 	+	prop as string  + separateur_params
					)
					ArrayParameter: (
						local tabString = ""
						for item in prop do
							tabString += item + "§"
						urba_clipboard_batiment+=  param as string  + separateur_mutation	+	tabString  + separateur_params
					)
					default:						(
						urba_clipboard_batiment+=  param as string  + separateur_mutation 	+	prop as string  + separateur_params
					)
				)
			) */
-- 			local props_noms 	= ( getPropNames _this )
-- 			for prop_nom in props_noms do	
-- 				if findItem params_aEnregistrer	prop_nom != 0 do
-- 					urba_clipboard_batiment+=  prop_nom as string  + "=" 	+	( getProperty  _this prop_nom ) as string  + ";"
		),
		
		fn coller _this =(
			
				set_Params 	_this 	urba_clipboard_batiment
			
					
-- 				setproperty 	_this 	nomProp	valProp
-- 				local valProp 	= execute ( param[2] )	
				
		)
		
)	--- fin struct ------









