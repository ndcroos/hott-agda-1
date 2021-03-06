{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude hiding (Z)
open FatPushoutFib
open ConnectedMap
open Truncation

{- TRANASLATION GUIDE:
 P : X → Y → Type
 Z = Σ x,y. P x y
 f : Z → X = π1 
 g : Z → Y = π1 o π2
 cf is equivalent to f (i.e. π1) being connected, and similarly for cg
-}
module homotopy.blakersmassey.SomewhatFibered (X Y : Type) (P : X → Y → Type)
                                              (i' j' : _)
                                              (cf : (x : X) → Connected (S i') (Σ \ y → P x y))
                                              (cg : (y : Y) → Connected (S j') (Σ \ x → P x y)) where

  i : TLevel
  i = S i'

  j : TLevel
  j = S j'

  i+j = plus2 i' j'

  W = FatPushoutFib.Pushout P
                                       

  Z = Σ (λ x → Σ (λ y → P x y)) 
  Z×YZ = Σ (λ (x1' : X) → Σ (λ (y' : Y) → Σ (λ (x2' : X) → P x1' y' × P x2' y')))
  Z×XZ = Σ (λ (y1' : Y) → Σ (λ (x' : X) → Σ (λ (y2' : Y) → P x' y1' × P x' y2')))
  Z×WZ = Σ \ (x1 : X) → Σ \ (y1 : Y) -> Σ \ (p1 : P x1 y1) -> 
                     Σ \ (x2 : X) → Σ \ (y2 : Y) -> Σ \ (p2 : P x2 y2) → Path{W} (inm p1) (inm p2) 

  glue-map : (x : X) (y : Y) → P x y → Path{W} (inl x) (inr y)
  glue-map x y p = gluer p ∘ ! (gluel p)

  -- TRANSLATION GUIDE:
  -- Z×WY = Pullback{W} inm inr
  -- Z×WX = Pullback{W} inm inl
  -- Z×WZ = Pullback{W} inm inm
  -- Z×XZ = Pullback{X} f f 
  -- Z×YZ = Pullback{Y} g g 

  -- TRANSLATION GUIDE: 
  -- here is why precodes-l is what it is:
  -- 
  -- ZxXZ → ZxWX
  -- expands to (x1,y1,p1) (x2,y2,p2) (p3 : y1 = y2) ->
  --            (x1,y1,p1) x2 such that inm(x1,y1,p1) == inl x2
  -- the map here was (z1 , z2 , p) = z1 , f z2 , ! (gluelr z2) ∘ ap inr p ∘ gluer z1
  -- 
  -- so the hfiber of this is those 
  --    x1 y1 p1 x2 α as below
  -- such that there exist (x1',y1',p1') (x2',y2',p2') (p3' : y1' = y2')
  --    such that ((x1,y1,p1),x2,α) == ((x1',y1',p1'),x2',!(gluelr x2' y2' p2') ∘ ap inr p3' ∘ gluer x1' y1' p1')
  --
  -- breaking apart the path in the Σ
  -- the hfiber of this is those 
  --    x1 y1 p1 x2 α as below
  -- such that there exist (x1',y1',p1') (x2',y2',p2') (p3' : y1' = y2') where
  --    (x1,y1,p1) == (x1',y1',p1')
  --    x2 == x2'
  --    α = !(gluelr x2' y2' p2') ∘ ap inr p3' ∘ gluer x1' y1' p1'
  --
  -- so we can contract away x1' y1' p1' x2' y2' by path induction, unifying
  --    x1 = x1'
  --    y1 = y1' = y2'
  --    p1 = p1'
  --    x2 = x2'
  --    p3 = refl
  -- which reduces the formula to 
  -- there exist p2' such that
  --    α = !(gluelr x2 y1 p2') ∘ gluer x1 y1 p1
  --
  -- rearrange to gluelr x2 y1 p2' = gluer x1 y1 p1 ∘ ! α per Eric
  
  -- HFiber of Z×YZ -> Z×WX
  precodes-l : (x1 : X) (y1 : Y) (p1 : P x1 y1) (x2 : X) (α : Path{W} (inm p1) (inl x2)) → Type
  precodes-l x1 y1 p1 x2 α = Σ (λ (p21 : P x2 y1) → (glue-map x2 y1 p21) == (gluer p1) ∘ ! α)

  -- HFiber of Z×XZ -> Z×WY
  precodes-r : (x1 : X) (y1 : Y) (p1 : P x1 y1) (y2 : Y) (α : Path{W} (inm p1) (inr y2)) → Type
  precodes-r x1 y1 p1 y2 α = Σ (λ (p12 : P x1 y2) → glue-map x1 y2 p12 == α ∘ ! (gluel p1))

  -- precodes-l pulled back along Z×WZ → Z×WX to be over Z×WZ;
  -- pullback is just substitution!
  precodes-l-Z : Z×WZ → Type
  precodes-l-Z (x1 , y1 , p1 , x2 , y2 , p2 , α) = 
       Σ (λ (p21 : P x2 y1) → glue-map _ _ p21 == (gluer p1) ∘ ! (gluel p2 ∘ α))

  -- precodes-r pulled back along Z×WZ → Z×WX to be over Z×WZ;
  precodes-r-Z : (x1 : X) (y1 : Y) (p1 : P x1 y1) 
             (x2 : X) (y2 : Y) (p2 : P x2 y2) → Path{W} (inm p1) (inm p2) → Type
  precodes-r-Z x1 y1 p1 x2 y2 p2 α = 
       Σ (λ (p12 : P x1 y2) → glue-map x1 y2 p12 == (gluer p2) ∘ α ∘ ! (gluel p1))

  ⟨Z×XZ⟩+Z⟨Z×YZ⟩ : Type
  ⟨Z×XZ⟩+Z⟨Z×YZ⟩ = Pushout.Pushout
        { Z }
        { Z×YZ }
        { Z×XZ } 
        (λ {(x , y , p) → (x , y , x , p , p)})
        (λ {(x , y , p) → (y , x , y , p , p)})
  
  precodes-m-map : ⟨Z×XZ⟩+Z⟨Z×YZ⟩ → Z×WZ
  precodes-m-map = (Pushout.Pushout-rec {C = Z×WZ}
          (λ {(x1' , y1' , x2' , p11' , p21')
            → (x1' , y1' , p11' , x2' , y1' , p21' , (! (gluer p21')) ∘ (gluer p11')) })
          (λ {(y1' , x1' , y2' ,  p11' , p12')
            → (x1' , y1' , p11' , x1' , y2' , p12' , (! (gluel p12')) ∘ gluel p11') }) 
          (λ z → ap
                   (λ h →
                      fst z ,
                      fst (snd z) , snd (snd z) , fst z , fst (snd z) , snd (snd z) , h)
                   (! (! (!-inv-l (gluer _)) ∘ !-inv-l (gluel _)))))
  
  precodes-m : Z×WZ → Type
  precodes-m z = HFiber precodes-m-map z


  module OverZ (x1 : X) (y1 : Y) (p1 : P x1 y1) where
    Z×X- = Σ \ y2 -> P x1 y2
    -×YZ = Σ \ x2 → P x2 y1

    -×WZ : Type
    -×WZ = Σ \ (x2 : X) -> Σ \ (y2 : Y) → Σ \ (p2 : P x2 y2) → Path{W} (inm p1) (inm p2)

    ⟨Z×X-⟩∨⟨-×YZ⟩ : Type
    ⟨Z×X-⟩∨⟨-×YZ⟩ = Pushout.Wedge { Z×X- } { -×YZ } (y1 , p1) (x1 , p1) 
    
    left-map : Z×X- → -×WZ
    left-map (y2 , p21) = x1 , y2 , p21 , ! (gluel p21) ∘ gluel p1

    right-map : -×YZ → -×WZ
    right-map (x2 , p21) = x2 , y1 , p21 , ! (gluer p21) ∘ gluer p1

    precodes-m-map-over : ⟨Z×X-⟩∨⟨-×YZ⟩ → -×WZ 
    precodes-m-map-over = Pushout.Pushout-rec left-map
                                              right-map 
                                              (λ _ → pair≃ id (pair≃ id (pair≃ id (! (!-inv-l (gluer _)) ∘ !-inv-l (gluel _)))))

    precodes-m-over : (x2 : X) (y2 : Y) (p2 : P x2 y2) → Path{W} (inm p1) (inm p2) → Type
    precodes-m-over x2 y2 p2 α = HFiber precodes-m-map-over (x2 , y2 , p2 , α)

    ZxX-xYZ = ((Σ \ y2 -> P x1 y2) × Σ \ x2 → P x2 y1)

  -- We now use the wedge into product and pre-post compose with the following equivalences as necessary

  Z×YZ×XZ : Type
  Z×YZ×XZ = Σ (λ (x1 : X) → Σ (λ (y1 : Y) → Σ (λ (x2 : X) → Σ (λ (y2 : Y) → P x1 y1 × P x2 y1 × P x2 y2))))

  pushout-to-pullback : ⟨Z×XZ⟩+Z⟨Z×YZ⟩ → Z×YZ×XZ
  pushout-to-pullback = Pushout.Pushout-rec {C = Z×YZ×XZ}
        (λ {(x1 , y1 , x2 , p11 , p21)
          → x1 , (y1 , (x2 , (y1 , (p11 , (p21 , p21))))) })
        (λ {(y1 , x1 , y2 ,  p11 , p12)
          → x1 , (y1 , (x1 , (y2 , (p11 , (p11 , p12))))) })
        (λ {(x , y , p) → id })

  total-lemma-1 : Equiv (Σ precodes-l-Z) Z×YZ×XZ
  total-lemma-1 = {!!} , {!!}

  total-lemma-2 : Equiv (Σ (λ {(x1 , y1 , p1 , x2 , y2 , p2 , α) → OverZ.precodes-m-over x1 y1 p1 x2 y2 p2 α})) ⟨Z×XZ⟩+Z⟨Z×YZ⟩
  total-lemma-2 = {!!}

  Z×X-×YZ : (x1 : X) (y1 : Y) (p1 : P x1 y1) → Type
  Z×X-×YZ x1 y1 p1 = OverZ.Z×X- x1 y1 p1 × OverZ.-×YZ x1 y1 p1

  total-lemma-3 : Equiv (Σ (λ {(x1 , y1 , p1) → OverZ.⟨Z×X-⟩∨⟨-×YZ⟩ x1 y1 p1})) ⟨Z×XZ⟩+Z⟨Z×YZ⟩
  total-lemma-3 = {!!}

  total-lemma-4 : Equiv (Σ (λ {(x1 , y1 , p1) → Z×X-×YZ x1 y1 p1})) Z×YZ×XZ
  total-lemma-4 = {!!}

  precodes-glue-l-map : ∀ zwz → precodes-m zwz → precodes-l-Z zwz
  precodes-glue-l-map (x1 , y1 , p11 , x2 , y2 , p22 , α) (w , X) = 
    Pushout.Pushout-elim
      (λ w₁ → (X₁ : precodes-m-map w₁ == (x1 , y1 , p11 , x2 , y2 , p22 , α)) → precodes-l-Z (x1 , y1 , p11 , x2 , y2 , p22 , α))
      {!!} {!!} {!!}
      w X

  precodes-glue-l' : ∀ zwz → Trunc i+j (precodes-m zwz) == Trunc i+j (precodes-l-Z zwz)
  precodes-glue-l' zwz = ua (ConnectedMap-Equiv i+j {!!} {!!})

  -- note: this proof may be a pain in the ass when we need to know what the equivalence is
  precodes-glue-l : ∀ x1 y1 p1 → (x : X) (y : Y) (p : P x y) →
      transport (λ w → Path (inm p1) w → Type) (gluel p)
      (λ α → Trunc i+j (precodes-m (x1 , y1 , p1 , x , y , p , α)))
      ≃ (λ α → Trunc i+j (precodes-l x1 y1 p1 x α))
  precodes-glue-l x1 y1 p1 x y p = λ≃ (λ α → (ap (Trunc i+j) (apΣ id (λ≃ (λ x₁ → ap
                                                                                (λ X₁ →
                                                                                   Id (gluer x₁ ∘ ! (gluel x₁)) (gluer p1 ∘ ! X₁))
                                                                                (!-inv-r-front (gluel  p) α)))) ∘ precodes-glue-l' (x1 , y1 , p1 , x , y , p , (! (gluel p) ∘ α)))
                                   ∘ ap (λ X₁ → Trunc i+j (precodes-m (x1 , y1 , p1 , x , y , p , X₁))) (transport-Path-right (! (gluel p)) α)) 
                                   ∘ transport-→-pre' (λ w → Path (inm p1) w) (gluel p) (λ α → Trunc i+j (precodes-m (x1 , y1 , p1 , x , y , p , α)))

  Codes : (x1 : X) (y1 : Y) (p1 : P x1 y1) (w : W) → Path (inm p1) w → Type
  Codes x1 y1 p1 = Pushout-elim (\ w -> Path (inm p1) w → Type)
                         (λ x2 α → Trunc i+j {! (precodes-l x1 y1 p1 x2 α) !}) 
                         (λ x2 y2 p2 α → Trunc i+j ({! precodes-m (x1 , y1 , p1 , x2 , y2 , p2 , α) !}))
                         (λ y2 α → Trunc i+j (precodes-r x1 y1 p1 y2 α))
                         {! (precodes-glue-l x1 y1 p1) !}
                         {!!}

  center :  (x1 : X) (y1 : Y) (p1 : P x1 y1) (w : W) (α : Path (inm p1) w) → (Codes x1 y1 p1 w α)
  center x1 y1 p1 .(inm p1) id = [ {!!} , {!!} ]

  Codes-contr : (x1 : X) (y1 : Y) (p1 : P x1 y1) (w : W) (α : Path (inm p1) w) → Contractible (Codes x1 y1 p1 w α)
  Codes-contr x1 y1 p1 w α = center x1 y1 p1 w α , {!the big diagram chase goes here!}

  cπ1 : ConnectedMap i {Σ \ x -> Σ \ y → P x y}{X} fst
  cπ1 = λ x → {!cf x!} -- and contract with J

  glue-map-total : Z → Σ \ x → Σ \ y → Path{W} (inl x) (inr y)
  glue-map-total (x , y , p) = (x , y , glue-map x y p)
  
  glue-map-connected''' : (x1 : X) (y1 : Y) (p1 : P x1 y1) 
                      → (y : Y) (α : Path {W} (inm p1) (inr y))
                      → Contractible (Trunc i+j (Σ \ (p2 : P x1 y) → glue-map x1 y p2 == α ∘ ! (gluel p1)))
  glue-map-connected''' x1 y1 p1 y = Codes-contr x1 y1 p1 (inr y)

  glue-map-connected'' : (x1 : X) (y1 : Y) (p1 : P x1 y1) 
                      → (y : Y) (α : Path {W} (inm p1) (inr y))
                      → Contractible (Trunc i+j (HFiber glue-map-total (x1 , y , α ∘ ! (gluel p1))))
  glue-map-connected'' = {!glue-map-connected''!} -- simplify HFiber of projections 

  -- suffices to consider glue-map-total o f(=π1) : Z×WY → W
  glue-map-connected' : (x1 : X) (y1 : Y) (p1 : P x1 y1) 
                      → (y : Y) (α : Path {W} (inl x1) (inr y))
                      → Contractible (Trunc i+j (HFiber glue-map-total (x1 , y , α)))
  glue-map-connected' = {!glue-map-connected''!}   -- because composition with ! (gluel x1 y1 p1) is an equivalence

  glue-map-connected : ((x : X) (y : Y) (α : Path{W} (inl x) (inr y)) 
            → Contractible (Trunc i+j (HFiber glue-map-total (x , y , α))))
  glue-map-connected x y α = extend i fst cπ1
                               (λ x' →
                                  ((y' : _) (p' : _) →
                                   Contractible (Trunc i+j (HFiber glue-map-total (x' , y' , p'))))
                                  ,
                                  raise-HProp (Πlevel (λ _ → Πlevel (λ _ → Contractible-is-HProp _))))
                               (λ p₁ → glue-map-connected' (fst p₁) (fst (snd p₁)) (snd (snd p₁))) x y α

  theorem : ConnectedMap i+j glue-map-total
  theorem (x , y , p) = ntype (glue-map-connected x y p) 
