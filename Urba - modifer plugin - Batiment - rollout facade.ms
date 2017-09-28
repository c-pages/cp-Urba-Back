
	------------------------------------------------------------------------------
	----------	Fenetre								 -------------------------
	------------------------------------------------------------------------------
	rollout roll_urba_editeurFacades "urba_editeurFacades" width:250 height:494
	(
		------------  Membres	----------------------------------------------------------------------------------
		---- Pointeurs ----
		local m_prt				---- pointeur vers la structure de controle ----
		
		---- Structures ----
		local m_drag			---- la structure gerant le drag de la fenetre ----
		
		--- ctro des imgtags ---
		local m_titre
		
		local m_cible		-- le plus cilb�
--- images bouton fermer ---
		local murs_types 	= #()
		local icos_fermer 	= #(	openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_R.jpg" ,		-- Repos ----
										openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_S.jpg" ,		-- Survol ----
										openBitMap "$userScripts\cp - GLOBAL\ico\ico_fermer_P.jpg" 			-- Press� ----
										)
		------------  UI	----------------------------------------------------------------------------------		
		---- le bouton pour fermer la fenetre ----
		ImgTag 'ui_btnFermer' "X" pos:[0,0] width:20 height:20 toolTip:"Fermer" style:#bmp_center align:#left

		ImgTag 'ui_titre' "" pos:[8,4] width:66 height:18 align:#left
	 
		
		edittext 'edt_nom_facade' "" pos:[85,50] width:153 height:16 align:#left
		label 'lbl_nom_facade' "Nom:" pos:[6,50] width:52 height:15 align:#left
		
		checkbox 'chk_repetable' "R�p�table" pos:[6,69] width:75 height:14 align:#left
		checkbox 'chk_etirable' "Etirable" pos:[6,87] width:64 height:14 align:#left
		spinner 'spn_proba' "" pos:[85,139] width:71 height:16 range:[0,1e+13,0] type:#float scale:1 align:#left
		label 'lbl_proba' "Probabilit�:" pos:[7,139] width:67 height:15 align:#left
		
		spinner 'spn_largeur' "" pos:[85,105] width:71 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		label 'lbl_largeur' "Largeur:" pos:[7,103] width:53 height:16 align:#left
		spinner 'spn_largeurMax' "" pos:[169,105] width:71 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		spinner 'spn_etages' "" pos:[85,122] width:71 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		label 'lbl_etages' "Etages:" pos:[7,121] width:46 height:16 align:#left
		spinner 'spn_etagesMax' "" pos:[169,122] width:71 height:16 range:[0,1e+13,0] type:#integer scale:1 align:#left
		
		
		dropdownList 'ddl_appliquerA' "" pos:[86,83] width:153 height:21 selection:3 align:#left		  items:murs_types
		label 'lbl_appliquerA' "Appliquer �:" pos:[85,68] width:111 height:15 align:#left
		
		checkbox 'chk_largeur' "" pos:[155,105] width:14 height:14 align:#left
		checkbox 'chk_etages' "" pos:[155,122] width:14 height:14 align:#left
		
		
		
		listbox 'lbx_composants' "" pos:[7,173] width:232 height:9 align:#left
		button 'btn_ajouter_composant' "+" pos:[209,157] width:16 height:16 align:#left
		button 'btn_supprimer_composant' "-" pos:[224,157] width:16 height:16 align:#left
		GroupBox 'grp3' "Propri�t�s" pos:[7,296] width:232 height:186 align:#left
		spinner 'spn_largeur_composant' "" pos:[85,314] width:67 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		label 'lbl11' "Largeur:" pos:[17,311] width:53 height:16 align:#left
		spinner 'spn_largeurMax_composant' "" pos:[167,314] width:67 height:16 range:[0,1e+13,0] type:#worldunits scale:1 align:#left
		checkbox 'chk__largeurMax_composant' "" pos:[152,315] width:14 height:14 align:#left
		listbox 'lbx_modeles' "" pos:[16,351] width:214 height:9 align:#left
		button 'btn_ajouter_modele' "+" pos:[200,335] width:16 height:16 align:#left
		button 'btn_supprimer_modele' "-" pos:[215,335] width:16 height:16 align:#left
		label 'lbl12' "Mod�les:" pos:[17,332] width:53 height:16 align:#left
		
		label 'lbl23' "S�quence" pos:[7,156] width:67 height:15 align:#left
		
		button 'btn_enregistrer' "Enregistrer " pos:[162,27] width:75 height:21 align:#left
		button 'btn_charger' "Charger" pos:[87,27] width:75 height:21 align:#left
		------------  Fonctions	----------------------------------------------------------------------------------
		---- Gere l'�tat du bouton  -----
		fn etatBtnFermer		_etat =(
			case _etat of (
				#Repos : 	ui_btnFermer.bitmap = icos_fermer[1]	
				#Survol : 	ui_btnFermer.bitmap = icos_fermer[2]	
				#Press : 	ui_btnFermer.bitmap = icos_fermer[3]	
			)
		)
		
		
		fn actualiser = (
			edt_nom_facade.text = m_prt.facade_courante.nom
		)
		
		---- Initialisation de la fenetre  -----
		fn initialiser = (
			
			m_drag 		= str_drag 	m_prt:roll_urba_editeurFacades		
			
			m_titre 		= str_label 	m_ui:ui_titre			m_texte:"Urba | Editeur de fa�ades"
			m_titre.setCouleur (color 0 0 0)
			m_titre.setCouleurFond ( color 200 200 200 )

			
			-- le bouton fermer --
			ui_btnFermer.pos = [roll_urba_editeurFacades.width - 20,0]
			ui_btnFermer.bitmap = icos_fermer[1]	
			
			actualiser()

		)
		
		
		------------  Evenements	----------------------------------------------------------------------------------
		
		---- Fermer ----
		
		---- Drag ----
		
		on chk_repetable			changed state do ()
		on chk_etirable			changed state do ()
			
		on spn_proba			changed val do ()
		on spn_largeur			changed val do ()
		on spn_largeurMax			changed val do ()
		on spn_etages			changed val do ()
		on spn_etagesMax			changed val do ()
		
-- 		on ddl_appliquerA
		on chk_largeur	changed state do ()
		on chk_etages	changed state do ()
-- 		on lbx_composants
		on btn_ajouter_composant				pressed do ()
		on btn_supprimer_composant		pressed do ()
		on spn_largeur_composant				changed val do ()
		on spn_largeurMax_composant			changed val do ()
		on chk__largeurMax_composant		changed state do ()
-- 		on lbx_modeles
		on btn_ajouter_modele					pressed do ()
		on btn_supprimer_modele				pressed do ()
		
		on edt_nom_facade entered 		txt 	do
			m_prt.set_nom 		txt		m_cible
		
		on roll_urba_editeurFacades lbuttondown _pos 	do
			m_drag.demarrer ()
		on roll_urba_editeurFacades lbuttonup _pos 	do
			m_drag.arreter ()
		on roll_urba_editeurFacades mouseMove _pos 	do
			m_drag.suivreSouris ()
		on ui_btnFermer mouseover do
			etatBtnFermer #Survol
		on ui_btnFermer mouseout do
			etatBtnFermer #Repos
		on ui_btnFermer mouseDown do
			etatBtnFermer #Press
		on ui_btnFermer mouseUp do
			etatBtnFermer #Repos
		on ui_btnFermer click do
			m_prt.fermer ()
		
		on btn_enregistrer pressed do
			m_prt.enregistrer  ()
		
		on btn_charger pressed do
			m_prt.charger ()
		
		
		
	)
			
		