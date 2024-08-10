- The root scene, called Main, is a Node 2D.

- As children of the root scene there is a Node2D called 'GridCarrier'.

- As a child of GridCarrier, a GridContainer called 'Board' has the script InstantiateButtons.gd attached, that instantiates 81 square TextureButton scenes to form a 9x9 grid.

- The corners, edges, and middle squares all have different TextureButtons, and the star points also have their own with names like: CenterButton, EdgeTop, CornerTopLeft, StarPointButton, etc. 

- Each TextureButton scene has the script called ButtonInteract.gd.

- TextureButton scenes have an AnimatedSprite2D as a child with the script called AnimationControl.gd attached to each.

- InstantiateButtons.gd, ButtonInteract.gd and AnimiaitonControl.gd all interact with a singleton script in autoload called GameState.gd.