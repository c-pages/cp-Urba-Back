unregisterRedrawViewsCallback GW_displayObjectNames
fn GW_displayObjectNames =
(
	gw.setTransform (matrix3 1)
	for o in objects where classof o ==urba_batiment  do (
		--     gw.text o.pos (o as string) color:yellow
		-- 	gw.Marker o.pos 	#hollowBox color:yellow
		
		
		local BB_axeP 	= o.BB_axePrincipal
		local mtrx_axeP	= o.mtrx_axePrincipal
		translate mtrx_axeP BB_axeP[1]
		
		local diag_axeP	=	(BB_axeP[2] * inverse mtrx_axeP) - (BB_axeP[1]  * inverse mtrx_axeP)
		local largeur 		=	diag_axeP.x
		local longeur 		= 	diag_axeP.z
		
		
		
		
		---- dessin de l'Axe-----------------
		local ptAxe_1 = (  [largeur/2,0,-100]  *  mtrx_axeP )
		local ptAxe_2 = (  [largeur/2,0,longeur + 100 ]  *  mtrx_axeP )
		
		gw.setColor	#line	blue
		gw.Polyline #( ptAxe_1, ptAxe_2 )	false
		
		
		---- dessin du BB-----------------
		local ptBB_1 = (  [0,0,0]  *  mtrx_axeP )
		local ptBB_2 = (  [0,0,longeur]  *  mtrx_axeP )
		local ptBB_3 = (  [largeur ,0,longeur]  *  mtrx_axeP )
		local ptBB_4 = (  [largeur ,0,0]  *  mtrx_axeP )

		gw.setColor	#line	yellow
		gw.Polyline #( ptBB_1, ptBB_2, ptBB_3, ptBB_4 )	true
		
	)
	gw.enlargeUpdateRect #whole  
)


registerRedrawViewsCallback GW_displayObjectNames





 



