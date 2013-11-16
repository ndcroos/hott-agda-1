{-# OPTIONS --without-K --type-in-type #-}

open import NoFunextPrelude

module Funext2 where

  Homotopies : Type → Type → Type
  Homotopies A B = (Σ \ (fg : (A -> B) × (A → B)) → (x : A) → fst fg x == snd fg x)

  -- uses η for Σ
  swap : ∀ {A B} → Equiv (A → Paths B) (Homotopies A B)
  swap = (improve (hequiv (λ h → ((λ x → fst (fst (h x))) , (λ x → snd (fst (h x)))) , (λ x → snd (h x))) 
                          (λ i → λ x → ((fst (fst i) x) , (snd (fst i) x)) , snd i x)
                          (λ _ → id) (λ _ → id)))
    -- this can be written with AC, but it's too annoying to do the beta reduction if you write it this way
    -- (apΣ-l' (AC {A = A} {B = λ _ → B} {C = λ _ _ → B})) ∘ ua (AC {A = A} {B = λ _ → B × B} {C = λ _ b1b2 → fst b1b2 == snd b1b2})
  
  abstract
    funextt : ∀ {A B} → Equiv (Paths (A → B)) (Homotopies A B)
    funextt {A} {B} = Paths (A → B) ≃〈 contract-Paths-eqv {A → B} 〉 
                      (A → B) ≃〈 coe-equiv (ap (λ y → A → y) (ua (!equiv (contract-Paths-eqv {B})))) 〉 
                      (A → Paths B) ≃〈 swap 〉 
                      Homotopies A B ∎∎
  
    funextt-id : ∀ {A B} (f : A → B) → fst funextt ((f , f) , id) == ((f , f) , λ x → id)
    funextt-id {A} f = fst funextt ((f , f) , id) =〈 id 〉 
                       fst swap (coe (ap (λ y → A → y) (ua (!equiv (contract-Paths-eqv)))) f) =〈 ap (fst swap) (ap= (! (transport-ap-assoc' (λ x → x) (λ y → A → y) (ua (!equiv contract-Paths-eqv))))) 〉 
                       fst swap (transport (λ y → A → y) (ua (!equiv (contract-Paths-eqv))) f) =〈 ap (fst swap) (transport-→-post (ua (!equiv contract-Paths-eqv)) f) 〉 
                       fst swap (coe (ua (!equiv (contract-Paths-eqv))) o f) =〈 ap (λ z → fst swap (z o f)) (type=β (!equiv contract-Paths-eqv)) 〉 
                       fst swap (fst (!equiv (contract-Paths-eqv)) o f) =〈 id 〉 
                       ((f , f) , (λ x → id)) ∎

  preserves-fst : ∀ {A B} → (α : Paths (A → B)) 
          → (fst (fst funextt α)) == fst α
  preserves-fst {A}{B} ((f , .f) , id) = ap fst (funextt-id f)

  funext : {A B : Type} (f g : A → B) → (f == g) ≃ ((x : A) → f x == g x)
  funext {A}{B} f g = fiberwise-equiv-from-total-eqv funextt preserves-fst (f , g)

  funext-id : {A B : Type} (f : A → B) → fst (funext f f) id == (λ x → id)
  funext-id {A} f = _ =〈  fiberwise-equiv-from-total-eqv-β funextt preserves-fst (f , f) id  〉
                      (transport (λ fg → (x : A) → Id (fst fg x) (snd fg x)) 
                                 (ap fst (funextt-id f))
                                 (snd (fst funextt ((f , f) , id)))) =〈 snd= (funextt-id f) 〉 
                      (λ x → id) ∎

  funext-ap= : {A B : Type} {f g : A → B} (α : f == g) → fst (funext f g) α == \ x -> ap= α {x}
  funext-ap= id = funext-id _

