; image.asm
;
; MI01 - TP Assembleur 2 à 5
;
; Réalise le traitement d'une image bitmap 32 bits par pixel.

title image.asm

.code

; **********************************************************************
; Sous-programme _process_image_asm 
; 
; Réalise le traitement d'une image 32 bits.
; 
; Le passage des paramètres respecte les conventions fastcall x64 sous 
; Windows. La fonction prend les paramètres suivants, dans l'ordre :
;  - biWidth : largeur d'une ligne en pixels (32 bits non signé)
;  - biHeight de l'image en lignes (32 bits non signé)
;  - img_src : adresse du premier pixel de l'image source
;  - img_temp1 : adresse du premier pixel de l'image temporaire 1
;  - img_temp2 : adresse du premier pixel de l'image temporaire 2
;  - img_dest : adresse du premier pixel de l'image finale

public  process_image_asm
process_image_asm 	proc		; Point d'entrée de la fonction


		;add rsp, 8 	;Pour 104 = 9 * 8, 13 étant le nombre d'éléments empilés, chacun faisant 8 octets
		pop r10 ; img_dest 
		pop r11 ; img_temp2
		sub rsp, 16 ; Retour au sommet de la pile

		push	rbx	;les registres rbx,rbp,rdi,rsi,rsp,r12,r13,r14,r15 doivent être sauvegardés par l'appelé, le reste est sauvegardé par l'appelant
		push	rbp
		push	rdi
		push	rsi
		push	rsp
		push	r12
		push	r13
		push	r14
		push	r15

		; Le passage de paramètre suis la convension fastcall 64
		; Les 4 premiers arguments sont passés dans rcx, rdx, r8 et r9 et le reste est mis sur la pile
		; biWidth	-> rcx
		; biHeight	-> rdx
		; img_src	-> r8
		; img_temp1	-> r9
		; Les 4 premiers sont dans le shadow space
		
		; img_temp2	-> r10
		; img_dest	-> r11
		
		
		imul rcx, rdx	; Le nombre de pixel.
		sub rcx, 1		; Nombre de pixel - 1 (Parade pour le problème r8) ; Devient donc l'adresse de la fin de l'image.

		
color:
			
		movzx rax, byte ptr [r8 + 4*rcx]		; byte ptr [r8 + 4*rcx] BLEU
		shl rax, 8		; On déplace le byte ptr de 8 vers la gauche (et donc ce qui avait à la place du byte ptr devient des 0) Tout ce qui est à gauche disparaît.
		imul rax, 1Dh
		mov r13, rax
		
		movzx rax, byte ptr [r8 + 4*rcx + 1]	; VERT
		shl rax, 8
		imul rax, 96h
		add r13, rax
		
		movzx rax, byte ptr [r8 + 4*rcx + 2]	; ROUGE
		shl rax, 8
		imul rax, 1Dh
		add r13, rax
		
		; r13 = 4C * Rouge + 96 * Vert + 1D * Bleu
		
		shr r13, 16		; On déplace le r13 de 16 bits vers la droite (on supprime donc la moitié) (en gros meme délire que la virgule)
		
		mov byte ptr [r9 + 4*rcx], r13b		; On stocke dans B et la technique du niveau gris.
		
		sub rcs, 1	; Décrémentation de l'index du pixel.
		cmp rcx, 0
		jne color



		pop		r15
		pop		r14
		pop		r13
		pop		r12
		pop		rsp
		pop		rsi
		pop		rdi
		pop		rbp
		pop		rbx
		
		;La fonction ne retourne rien
		ret						; Retour à la fonction d'appel
process_image_asm   endp

end
