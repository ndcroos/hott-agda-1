{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude hiding (Z)
open FatPushoutFib
open ConnectedMap
open Truncation
open import lib.cubical.Cubical

module homotopy.blakersmassey.ooTopos (X Y : Type) (P : X → Y → Type)
                                      (i' j' : TLevel)
                                      (cf : (x : X) → Connected (S i') (Σ \ y → P x y))
                                      (cg : (y : Y) → Connected (S j') (Σ \ x → P x y)) where 

  -- trivial by equiv induction, but easier if it computes
  HFiber-at-equiv : ∀ {A B B'} (e : Equiv B B') (f : A → B') {b : B}
                  → Equiv (HFiber f (fst e b)) (HFiber (IsEquiv.g (snd e) o f) b)
  HFiber-at-equiv e f {b} = improve (hequiv (λ p → (fst p) , {!snd p!}) {!!} {!!} {!!})

  post∘-equiv : ∀ {A} {a1 a2 a3 : A} (p : a2 == a3) → Equiv (a1 == a2) (a1 == a3)
  post∘-equiv p = improve (hequiv (λ x → p ∘ x) (λ x → ! p ∘ x) {!!} {!!})

  i : TLevel
  i = S i'

  j : TLevel
  j = S j'

  i+j = plus2 i' j'

  W = FatPushoutFib.Pushout P
  Z = Σ \xy → P (fst xy) (snd xy)

  glue : {x : X} {y : Y} (p : P x y) → Path {W} (inl x) (inr y)
  glue p = gluer p ∘ ! (gluel p)

  Z×WZ = Σ \ (z1 : Z) → Σ \ (z2 : Z) → Path {W} (inm (snd z1)) (inm (snd z2))
  -- 〈Z×Z〉×〈XY〉Z = Σ \ (z1 : Z) → Σ \ (z2 : Z) → P (fst (fst z1)) (snd (fst z2))
  〈Z×Z〉×〈YX〉Z = Σ \ (z1 : Z) → Σ \ (z2 : Z) → P (fst (fst z2)) (snd (fst z1))

  module Wedge = Pushout

  module _ {x0 : X} {y0 : Y} (p0 : P x0 y0) where
    gluel0 : {x : X} → P x y0 → Path {W} (inm p0) (inl x)
    gluel0 pxy0 = ! (glue pxy0) ∘ gluer p0

    gluer0 : {y : Y} → P x0 y → Path {W} (inm p0) (inr y)
    gluer0 pxy0 = glue pxy0 ∘ gluel p0

    gluemr : ∀ {x y} (pxy : P x y) → P x0 y → Path {W} (inm p0) (inm pxy)
    gluemr pxy px0y = ! (gluer pxy) ∘ glue px0y ∘ gluel p0

    glueml : ∀ {x y} (pxy : P x y) → P x y0 → Path {W} (inm p0) (inm pxy)
    glueml pxy pxy0 = ! (gluel pxy) ∘ ! (glue pxy0) ∘ gluer p0

    -×WZ = Σ \ (p : Z) → Path{W} (inm p0) (inm (snd p))
    -×XZ = (Σ \ y → P x0 y)
    -×YZ = (Σ \ x → P x y0)
    Z×X-∨-×YZ = Pushout.Wedge { -×XZ } { -×YZ } (_ , p0) (_ , p0)

    gluem : Z×X-∨-×YZ → -×WZ
    gluem = Wedge.Pushout-rec (λ ppx0y → (_ , snd ppx0y) , ! (gluel (snd ppx0y)) ∘ gluel p0)
                              (λ ppxy0 → (_ , snd ppxy0) , ! (gluer (snd ppxy0)) ∘ gluer p0)
                              (λ _ → pair= id (hom-to-over (square-to-disc (inverses-square (gluel p0) (gluer p0)))))

    wtp : Z×X-∨-×YZ → -×XZ × -×YZ 
    wtp = Pushout.wedge-to-prod

  module CodesGlueMaps where

    reassoc-l : 〈Z×Z〉×〈YX〉Z → Σ \(z : Z) → (-×XZ (snd z)) × (-×YZ (snd z))
    reassoc-l (((x , y) , pxy) , ((x' , y') , px'y') , px'y) = ((x' , y) , px'y) , ((y' , px'y') , (x , pxy))

    reassoc-r : (Σ \(z : Z) → (-×XZ (snd z)) × (-×YZ (snd z))) → 〈Z×Z〉×〈YX〉Z
    reassoc-r (((x' , y) , px'y) , ((y' , px'y') , (x , pxy))) = (_ , pxy) , (_ , px'y') , px'y

    reassoc-eqv : Equiv 〈Z×Z〉×〈YX〉Z (Σ \(z : Z) → (-×XZ (snd z)) × (-×YZ (snd z)))
    reassoc-eqv = improve (hequiv reassoc-l reassoc-r (λ _ → id) (λ _ → id))

    switchr : (Σ \ (z : Z) → Z×X-∨-×YZ (snd z)) → (Σ \ (z : Z) → Z×X-∨-×YZ (snd z))
    switchr (z , w) = Wedge.Pushout-rec (λ z' → z , Wedge.inl z')
                                        (λ z' → (_ , snd z') , Wedge.inr (_ , snd z))
                                        (λ _ → ap (λ Z₁ → ((fst (fst z) , snd (fst z)) , snd z) , Z₁) (Wedge.glue _)) 
                                        w

    switchr-twice : ∀ z w → switchr (switchr (z , w)) == (z , w)
    switchr-twice z = Wedge.Pushout-elim _ (λ _ → id) (λ _ → id) (λ _ → {!!})

    switchr-equiv : Equiv (Σ \ (z : Z) → Z×X-∨-×YZ (snd z)) (Σ \ (z : Z) → Z×X-∨-×YZ (snd z))
    switchr-equiv = improve (hequiv switchr switchr (\ p → switchr-twice (fst p) (snd p)) (\ p → switchr-twice (fst p) (snd p)))

    gluem-total : Σ (λ z → Z×X-∨-×YZ (snd z)) → Z×WZ
    gluem-total = fiberwise-to-total (\ (z : Z) → gluem (snd z))

    glueml-total : 〈Z×Z〉×〈YX〉Z → Z×WZ
    glueml-total = (fiberwise-to-total (\ (ppp0 : Z) → (fiberwise-to-total (\ (ppxy : Z) → glueml (snd ppp0) (snd ppxy)))))

    m-to-ml : (Σ \ (z : Z) → Z×X-∨-×YZ (snd z)) → 〈Z×Z〉×〈YX〉Z
    m-to-ml = reassoc-r o fiberwise-to-total (λ z1 → wtp (snd z1)) o switchr

    m-to-ml-triangle : ∀ z (w : Z×X-∨-×YZ (snd z)) → (glueml-total o m-to-ml) (z , w) == gluem-total (z , w)
    m-to-ml-triangle z = Wedge.Pushout-elim (λ w → (glueml-total o m-to-ml) (z , w) == gluem-total (z , w))
                                            (λ yp → ap (λ Q → z , ((fst (fst z) , fst yp) , snd yp) , Q) {!!})
                                            (λ xp → ap (λ Q → z , ((fst xp , snd (fst z)) , snd xp) , Q) {!!})
                                            {!!}


  module OverZ {x0 : X} {y0 : Y} (p0 : P x0 y0) where

    open CodesGlueMaps

    glue-l-ml : ∀ {x y} (pxy : P x y) {αm : Path (inm p0) (inm pxy)} {αl : Path (inm p0) (inl x)} (s : ((gluel pxy) ∘ αm) == αl)
              → Equiv (Trunc i+j (HFiber (gluel0 p0) αl)) (Trunc i+j (HFiber (glueml p0 pxy) αm))
    glue-l-ml pxy id = apTrunc' (HFiber-at-equiv (post∘-equiv (gluel pxy)) (gluel0 p0))

    glue-ml-m : ∀ {x y} (pxy : P x y) {αm : Path (inm p0) (inm pxy)} 
              → Equiv (Trunc i+j (HFiber (gluem p0) ((_ , pxy) , αm))) (Trunc i+j (HFiber (glueml p0 pxy) αm))
    glue-ml-m {x}{y} pxy {α} = apTrunc' (!equiv step3) ∘equiv 
                               step2 ∘equiv
                               apTrunc' step1 where
              
      step2 : Equiv (Trunc i+j (HFiber gluem-total ((_ , p0) , (_ , pxy) , α)))
                    (Trunc i+j (HFiber glueml-total ((_ , p0) , (_ , pxy) , α)))
      step2 = ConnectedMap-fiber-top-equiv (m-to-ml) _ _ (λ≃ (\ q → m-to-ml-triangle (fst q) (snd q))) 
        (precompose-equiv-connected _ switchr-equiv
          (postcompose-equiv-connected _ (!equiv reassoc-eqv) 
            (fiberwise-to-total-connected i+j (λ _ → Wedge.wedge-to-prod)
              (λ z → Wedge.WedgeToProd.connected (_ , snd z) (_ , snd z) (cf _) (cg _))))) 

      step1 : Equiv (HFiber (gluem p0) ((_ , pxy) , α)) 
                    (HFiber gluem-total ((_ , p0) , (_ , pxy) , α))
      step1 = HFiber-fiberwise-to-total-eqv _

      step3 : Equiv (HFiber (glueml p0 pxy) α) 
                    (HFiber glueml-total ((_ , p0) , (_ , pxy) , α))
      step3 = (HFiber-fiberwise-to-total-eqv _) ∘equiv (HFiber-fiberwise-to-total-eqv _)

    CodesFor : (w : W) (p : Path{W} (inm p0) w) → Type 
    CodesFor = Pushout-elim _ (λ x α → Trunc i+j (HFiber (gluel0 p0) α)) 
                              (λ x y p α → Trunc i+j (HFiber (gluem p0) ( (_ , p) , α)))
                              (λ y α → Trunc i+j (HFiber (gluer0 p0) α))
                              (λ x y pxy → coe (! PathOverΠ-NDrange) (λ αm αl d → ua (!equiv (glue-l-ml pxy (square-to-disc (PathOverPathFrom.out-PathOver-= d))) ∘equiv glue-ml-m pxy)))
                              {!!} -- (λ αx αy s → ua (Codes-glue.eqv p0 pxy (PathOverPathFrom.out-PathOver-= s))))

    CodesFor' : (Σ \ (w : W) → Path{W} (inm p0) w) → Type 
    CodesFor' = uncurryd CodesFor

{-
    transport-CodesFor'-glue : ∀ {x y} (pxy : P x y) {αx  : Path{W} (inl x0) (inl x)} {αy  : Path (inl x0) (inr y)} (s : PathOver (Path (inl x0)) (glue pxy) αx αy)
                               → transport CodesFor' (pair= (glue pxy) s) == Codes-glue.map p0 pxy (PathOverPathFrom.out-PathOver-= s) 
    transport-CodesFor'-glue pxy s = transport CodesFor' (pair= (glue pxy) s) ≃〈 transport-ap-assoc CodesFor' (pair= (glue pxy) s) 〉 
                                     coe (ap CodesFor' (pair= (glue pxy) s)) ≃〈 ap coe (ap-uncurryd-NDrange CodesFor _ _) 〉 
                                     coe (coe PathOverΠ-NDrange (apdo CodesFor (glue pxy)) _ _ s) ≃〈 ap (λ Z → coe (coe PathOverΠ-NDrange Z _ _ s)) (Pushout-elim/βglue _ _ _ (λ x y pxy₁ → coe (! PathOverΠ-NDrange) (λ αx αy s₁ → ua (Codes-glue.eqv p0 pxy₁ (PathOverPathFrom.out-PathOver-= s₁)))) _ _ _) 〉 
                                     coe (coe PathOverΠ-NDrange (coe (! PathOverΠ-NDrange)
                                           (λ αx αy s → ua (Codes-glue.eqv p0 pxy (PathOverPathFrom.out-PathOver-= s)))) _ _ s) ≃〈 ap (λ z → coe (z _ _ s)) (IsEquiv.β (snd (coe-equiv PathOverΠ-NDrange)) _) 〉 
                                     coe (ua (Codes-glue.eqv p0 pxy (PathOverPathFrom.out-PathOver-= s))) ≃〈 type≃β (Codes-glue.eqv p0 pxy (PathOverPathFrom.out-PathOver-= s)) 〉 
                                     Codes-glue.map p0 pxy (PathOverPathFrom.out-PathOver-= s) ∎
-}
    forid : CodesFor (inm p0) id
    forid = [ Wedge.inl (_ , p0) , {!!} ]

    encode : (w : W) (p : inm p0 == w) → (CodesFor w p)
    encode x p = transport CodesFor' (pair= p connOver) forid

    redm : {y : Y} (px0y : P x0 y) → Path (encode (inr y) (glue px0y ∘ gluel p0)) [ px0y , id ]
    redm px0y = {!!}
{-
    redr px0y = transport CodesFor' (pair= (glue px0y) connOver) forid ≃〈 ap≃ (transport-CodesFor'-glue px0y connOver) 〉 
                Codes-glue.map p0 px0y (PathOverPathFrom.out-PathOver-= connOver) [ p0 , !-inv-l (glue p0) ]  ≃〈 id 〉 
                Trunc-rec Trunc-level (λ c → [ fst c , square-to-disc (PathOverPathFrom.out-PathOver-= connOver) ∘
                                                         ap (_∘_ (glue px0y)) (!-inv-l (glue p0)) ∘
                                                         square-to-disc-rearrange (square-symmetry (snd c)) ]) (composeP px0y p0 p0 ) ≃〈 ap (Trunc-rec Trunc-level (λ c → [ fst c , _ ])) (composePβ2 _ _) 〉 
                [ px0y , square-to-disc (PathOverPathFrom.out-PathOver-= connOver) ∘ ap (_∘_ (glue px0y)) (!-inv-l (glue p0)) ∘ square-to-disc-rearrange (square-symmetry (inverses-square (glue p0) (glue px0y))) ] ≃〈 ap (λ z → [ px0y , z ]) (coh (glue p0) (glue px0y)) 〉 
                [ px0y , id ] ∎ where
         coh : ∀ {A : Type} {a0 a1 a1' : A} (α : a0 == a1) (α' : a0 == a1')
               → square-to-disc (PathOverPathFrom.out-PathOver-= connOver) ∘ 
                  ap (_∘_ α') (!-inv-l α) ∘ 
                  square-to-disc-rearrange (square-symmetry (inverses-square α α')) == id
         coh id id = id
-}

    encode-decode-inm : (y : Y) (p : inm p0 == inr y) (c : HFiber (gluer0 p0) p) → Path (encode (inr y) p) [ c ]
    encode-decode-inm y ._ (px0y , id) = redm px0y

    contr-r : (y : Y) (p : Path{W} (inm p0) (inr y)) → Contractible (CodesFor (inr y) p)
    contr-r y p = encode (inr y) p , Trunc-elim _ (λ _ → path-preserves-level Trunc-level) (encode-decode-inm y p)

    -- move the problem to one of the inm --> inr paths, instead of the whole inl --> inr path,
    -- (otherwise we could do codes on (inl x0) == -, but doing codes on (inm p0) == - is more symmetric)
    gluer0-connected : (y : Y) → ConnectedMap i+j (gluer0 p0 {y})
    gluer0-connected y = λ α → ntype (contr-r y α)

    glue-as-gluer0 : (y : Y) → glue{x0}{y} == (\ z → z ∘ ! (gluel p0)) o gluer0 p0
    glue-as-gluer0 y = λ≃ (λ z → coh (glue z) (gluel p0)) where 
      coh : {A : Type} {a b c : A} (α : a == b) (β : c == a) → α == ((α ∘ β) ∘ ! β)
      coh id id = id

    -- if f is connnected then e o f is connected for an equivalence e,
    -- and use glue-as-gluer0
    glue-connected' : (y : Y) → ConnectedMap i+j (glue{x = x0} {y})
    glue-connected' y  = transport (\ Z → ConnectedMap i+j Z) (! (glue-as-gluer0 y)) (postcompose-equiv-connected (gluer0 p0) (pre∘-equiv (! (gluel p0))) (gluer0-connected y))

  -- make y0,p0 : P x0 y0 using connectivity 
  -- Z -> X is (S _)-connected, so to make an hprop for X, we can do it for Z
  glue-connected : (x0 : X) (y : Y) → ConnectedMap i+j (glue{x = x0}{y})
  glue-connected x0 y = Trunc-rec (raise-HProp (Πlevel (\ _ → (NType-is-HProp _)))) (λ yp0 → OverZ.glue-connected' (snd yp0) y)
                                  (fst (use-level (cf x0)))

  glue-map-total : (Σ \ xy → P (fst xy) (snd xy)) → Σ \ xy → Path{W} (inl (fst xy)) (inr (snd xy))
  glue-map-total ((x , y) , p) = ((x , y) , glue p)

  theorem : ConnectedMap i+j glue-map-total
  theorem = fiberwise-to-total-connected i+j (λ _ → glue) (λ xy → glue-connected (fst xy) (snd xy))
