{-# OPTIONS --without-K --type-in-type #-}

open import NoFunextPrelude
open import Funext2 using (funext ; funext-ap=) 

module FunextDep where

  λ= : {A B : Type} {f g : A → B} → ((x : A) → f x == g x) → f == g
  λ= α = IsEquiv.g (snd (funext _ _)) α

  -- need to do this as functions for use below
  ap=λ= : {A B : Type} {f g : A → B} → ((\ α x → ap={_}{_}{f}{g} α {x}) o (λ= {_}{_}{f}{g})) == (λ x → x)
  ap=λ= = λ= (λ x → IsEquiv.β (snd (funext _ _)) x ∘ ! (funext-ap= (λ= x)))

  Π : (A : Type) (B : A → Type) → Type
  Π A B = (x : A) → B x

  transport-Π-post : {A : Type} {B B' : A → Type} (e : B == B')
                   → transport (\ B → Π A B) e == (λ f x → coe (ap= e) (f x))
  transport-Π-post id = id

  _od_ : {A : Type} {B : A → Type} {C : A → Type} → (g : (x : A) → B x → C x) (f : Π A B) → (x : A) → C x
  g od f = \ x -> g x (f x)

  transport-Π-post' : {A : Type} {B B' : A → Type} (e : (x : A) → B x ≃ B' x) (f : (x : A) → B x)
                   → transport (\ B → Π A B) (λ= (\ x -> ua (e x))) f == (λ x → fst (e x)) od f
  transport-Π-post' {A}{B}{B'} e f = ap (λ z → z od f) STS ∘
                             ap=
                             (ap {M = (λ α x → ap= α {x}) o λ=} {N = λ x → x}
                              (λ z → λ f₁ x → coe (z (λ x₁ → ua (e x₁)) x) (f₁ x)) ap=λ=
                              ∘ transport-Π-post (λ= (λ x → ua (e x)))) where
                 Stuck : Path{(x : A) → Equiv (B x) (B' x) → B x → B' x}
                             (\ (x : A) → (coe o ua{B x}{B' x}))
                             (\ x -> fst)
                 Stuck = {!!}

                 STS : (\ x -> (coe o ua{B x}{B' x})) od e == \ x -> fst (e x)
                 STS = ap (λ z → z od e) Stuck


  Homotopies : (A : Type) → (A → Type) → Type
  Homotopies A B = (Σ \ (fg : (Π A B) × (Π A B)) → (x : A) → fst fg x == snd fg x)

  -- uses η for Σ
  rearrange : ∀ {A B} → Equiv ((x : A) → Paths (B x)) (Homotopies A B)
  rearrange = (improve (hequiv (λ h → ((λ x → fst (fst (h x))) , (λ x → snd (fst (h x)))) , (λ x → snd (h x))) 
                          (λ i → λ x → ((fst (fst i) x) , (snd (fst i) x)) , snd i x)
                          (λ _ → id) (λ _ → id)))
    -- this can be written with AC, but it's too annoying to do the beta reduction if you write it this way
    -- (apΣ-l' (AC {A = A} {B = λ _ → B} {C = λ _ _ → B})) ∘ ua (AC {A = A} {B = λ _ → B × B} {C = λ _ b1b2 → fst b1b2 == snd b1b2})

  abstract
    funextt : ∀ {A B} → Equiv (Paths ((x : A) → B x)) (Homotopies A B)
    funextt {A} {B} = Paths ((x : A) → B x) ≃〈 contract-Paths≃ 〉 
                      ((x : A) → B x) ≃〈 coe-equiv (ap {M = B} {N = Paths o B} (\ B -> Π A B) (IsEquiv.g (snd (funext _ _)) (λ x → ua (!equiv contract-Paths≃)))) 〉 
                      ((x : A) → Paths (B x)) ≃〈 rearrange 〉 
                      Homotopies A B ∎∎

    funextt-id : ∀ {A} {B : A → Type} (f : (x : A) → B x) → fst funextt ((f , f) , id) == ((f , f) , λ x → id)
    funextt-id {A}{B} f = fst funextt ((f , f) , id) =〈 id 〉 
                          fst rearrange (coe (ap {M = B} {N = Paths o B} (λ y → (x : A) → y x) (IsEquiv.g (snd (funext _ _)) (λ x → ua (!equiv contract-Paths≃)))) f) =〈 {!!} 〉 
                          fst rearrange (transport (λ y → Π A y) (λ= (λ x → ua (!equiv contract-Paths≃))) f) =〈 ap (fst rearrange) (transport-Π-post' (λ x → !equiv contract-Paths≃) _) 〉 
                          fst rearrange (\ x -> fst (!equiv (contract-Paths≃ {B x})) (f x)) =〈 id 〉 
                          (((f , f) , (λ x → id)) ∎)

  preserves-fst : ∀ {A} {B : A → Type} → (α : Paths ((x : A) → B x)) 
          → (fst (fst funextt α)) == fst α
  preserves-fst {A}{B} ((f , .f) , id) = ap fst (funextt-id f)


  funextd : {A : Type} {B : A → Type} (f g : (x : A) → B x) → (f == g) ≃ ((x : A) → f x == g x)
  funextd {A}{B} f g = fiberwise-equiv-from-total≃ funextt preserves-fst (f , g)


