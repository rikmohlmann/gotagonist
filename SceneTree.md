The root scene, called Main, is a Node 2D.
As children of the root scene there is a Node2D called 'GridCarrier'
As a child of GridCarrier, a GridContainer called 'Board' has the script InstantiateScene.gd attached, that instantiates 81 TextureButton scenes to form a 9x9 grid.
The corners, edges, middle and star points all have different TextureButtons, with names like: CenterButton, EdgeTop, CornerTopLeft, StarPointButton, etc.
Each TextureButton scene has the script called ButtonInteract.gd.
TextureButton scenes have AnimatedSprite2D as a child with the script called AnimationControl.gd attached to each.
InstantiateScene.gd, ButtonInteract.gd and AnimiaitonControl.gd all interact with singleton scripts in autoload called GameState.gd. and GoLogic.gd.