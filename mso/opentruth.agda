
{-# OPTIONS --type-in-type --without-K #-}

open import lib.Prelude
open import mso.Signatures
open import mso.Formulas
open import mso.ClosedTruth

open ListM
open Index

module mso.opentruth where

  ValueOpen : Subset → SigThing → Type
  ValueOpen A (i τ) = Maybe (IndividS A τ)  --could be a nil but only for a nullary const.
  ValueOpen A (r τs) = (IndividsS A τs → Type)
  --interpreting a signature; result type of get

  getOpen : ∀ {Σ oc} {st : SigThing}
      → st ∈ Σ
      → (A : Structure oc Σ)
      → ValueOpen (fst A) st
  getOpen i0 (A , (_ ,is a)) = Some a
  getOpen i0 (A , (_ ,rs rel)) = rel
  getOpen i0 (A , (_ ,none)) = None
  getOpen (iS i1) (A , SA ,is _) = getOpen i1 (A , SA)
  getOpen (iS i1) (A , SA ,rs _) = getOpen i1 (A , SA)
  getOpen (iS i1) (A , SA ,none) = getOpen i1 (A , SA)
  --lokup in signature

  getsOpen : ∀ {Σ oc} {τs : List Tp}
       → Terms Σ τs
       → (A : Structure oc Σ)
       → Maybe (IndividsS (fst A) τs)   --wanna make sure ALL constant are in domain
  getsOpen [] A = Some <>
  getsOpen (x ,t xs) A  with  (getsOpen xs A) | (getOpen x A)
  ... | Some vs | Some v = Some (vs , v)  --making sure all elements are interpreted
  ... | _ | _ = None  --if not it's dead to us

  --lets you look up a bunch of terms
--predicate identiftying existential formulas bc we need to use uni rules for uni formulas
  data isE {Σ : Signature} : Formula Σ → Type where
    isEexistsi : ∀ {τ} {φ : Formula (i τ :: Σ )} → isE (∃i τ φ)
    isEexistsr :  ∀ {τ} {φ : Formula (r (τ :: []) :: Σ )} → isE (∃p τ φ)
    isEor :  ∀ {φ1 φ2 : Formula Σ } → isE (φ1 ∨ φ2)
    isEfalse : ∀ {φ : Formula Σ } → isE ⊥

--predicate for universal formulas
  data isU {Σ : Signature} : Formula Σ → Type where
    isUforalli : ∀ {τ} {φ : Formula (i τ :: Σ )} → isU (∀i τ φ)
    isUforallr : ∀ {τ} {φ : Formula (r (τ :: []) :: Σ )} → isU (∀p τ φ)
    isUand :  ∀ {φ1 φ2 : Formula Σ } → isU (φ1 ∧ φ2)
    isUtrue :  ∀ {φ : Formula Σ } → isU ⊤

  data ubranch {Σ1 : Signature} : ∀ { Σ2 : Signature} {oc1 oc2} (A1 : Structure oc1 Σ1) (φ1 : Formula Σ1) (A2 : Structure oc2 Σ2) (φ2 : Formula Σ2) → Type where
    ufstb : ∀ {oc} {A1 : Structure oc Σ1} → {φ1 φ2 : Formula Σ1} → ubranch A1 (φ1 ∧ φ2) A1 φ1
    usndb : ∀ {oc} {A1 : Structure oc Σ1} → {φ1 φ2 : Formula Σ1} → ubranch A1 (φ1 ∧ φ2) A1 φ2
    uforallb : ∀ {oc} {τ} {A1 : Structure oc Σ1} → {φ : Formula (i τ :: Σ1 )} (a : IndividS (fst A1) τ) → ubranch A1 (∀i τ φ) (fst A1 , (snd A1) ,is a) φ
    uforallnil : ∀ {oc} {τ} {A1 : Structure oc Σ1} → {φ : Formula (i τ :: Σ1 )}  → ubranch A1 (∀i τ φ) (fst A1 , (snd A1) ,none) φ
    uforallr : ∀ {oc} {τ} {A1 : Structure oc Σ1} → {φ : Formula (r (τ :: []) :: Σ1 )} (r : IndividsS (fst A1) (τ :: []) → Type) → ubranch A1 (∀p τ φ) (fst A1 , (snd A1) ,rs r) φ

--make ebranch (did I do this right?)
  data ebranch {Σ1 : Signature} : ∀ { Σ2 : Signature} {oc1 oc2} (A1 : Structure oc1 Σ1) (φ1 : Formula Σ1) (A2 : Structure oc2 Σ2) (φ2 : Formula Σ2) → Type where
    efstb : ∀ {oc} {A1 : Structure oc Σ1} → {φ1 φ2 : Formula Σ1} → ebranch A1 (φ1 ∨ φ2) A1 φ1
    esndb : ∀ {oc} {A1 : Structure oc Σ1} → {φ1 φ2 : Formula Σ1} → ebranch A1 (φ1 ∨ φ2) A1 φ2
    eExistsb : ∀ {oc} {τ} {A1 : Structure oc Σ1} → {φ : Formula (i τ :: Σ1 )} (a : IndividS (fst A1) τ) → ebranch A1 (∃i τ φ) (fst A1 , (snd A1) ,is a) φ
    eExistsr : ∀ {oc} {τ} {A1 : Structure oc Σ1} → {φ : Formula (r (τ :: []) :: Σ1 )} (r : IndividsS (fst A1) (τ :: []) → Type) → ebranch A1 (∃p τ φ) (fst A1 , (snd A1) ,rs r) φ


--overarching branch
  data branch {Σ1 : Signature} : ∀ { Σ2 : Signature} {oc1 oc2} (A1 : Structure oc1 Σ1) (φ1 : Formula Σ1) (A2 : Structure oc2 Σ2) (φ2 : Formula Σ2)
                                 (pf : Either (isE φ1) (isU φ1)) (br : Either (ebranch A1 φ1 A2 φ2) (ubranch A1 φ1 A2 φ2)) → Type where
    ebr : ∀ {Σ2} {oc1 oc2} {A1 : Structure oc1 Σ1} {φ1 : Formula Σ1} {A2 : Structure oc2 Σ2} {φ2 : Formula Σ2} {pf : isE φ1} {br : ebranch A1 φ1 A2 φ2} → branch A1 φ1 A2 φ2 (Inl pf) (Inl br)
    ubr : ∀ {Σ2} {oc1 oc2} {A1 : Structure oc1 Σ1} {φ1 : Formula Σ1} {A2 : Structure oc2 Σ2} {φ2 : Formula Σ2} {pf : isU φ1} {br : ubranch A1 φ1 A2 φ2}→ branch A1 φ1 A2 φ2 (Inr pf) (Inr br)

  -- open TRUTH: i.e. the structure is open, but the formula is really provable anyway
  data _⊩o_ {oc : _} {Σ : _} (A : Structure oc Σ) : Formula Σ → Type where
    provesu : {φ : Formula Σ}
            → isU φ
            → (∀ {Σ' oc'} {A' : Structure oc' Σ'} {φ'} → ubranch A φ A' φ' → A' ⊩o φ')
            → A ⊩o φ
    provese : {φ : Formula Σ}
            → isE φ
            → ∀ {Σ' oc'} {A' : Structure oc' Σ'} {φ'} → ebranch A φ A' φ' → A' ⊩o φ' --do I need to switch the quantifier here (at the beginning of the line)?
            → A ⊩o φ
    --existential case for above; just use ebranch above, take out parens, switch quant
    provesbase : ∀ {τs} {rel} {xs : Terms _ τs} vs → ((getsOpen xs A) == (Some vs)) → (getOpen rel A) (vs) → A ⊩o (R rel xs)
    provesnotbase : ∀ {τs} {rel} {xs : Terms _ τs} → (Σ \ vs -> ((getsOpen xs A == (Some vs))) → ((getOpen rel A) (vs) → Void)) →  A ⊩o (¬R rel xs)

{-
  (A , SA) ⊩o ∀i τ φ = ((a : IndividS A τ) → (A , (SA ,is a)) ⊩o φ) × ((A , (SA ,none)) ⊩o φ)
  (A , SA) ⊩o ∃i τ φ = (Σ \ (a : IndividS A τ) → (A , (SA ,is a)) ⊩o φ) --took out nils here
  (A , SA) ⊩o ∀p τ φ = (P : Unit × IndividS A τ → Type) → (A , (SA ,rs P)) ⊩o φ
  (A , SA) ⊩o ∃p τ φ = Σ \ (P : Unit × IndividS A τ → Type) → (A , (SA ,rs P)) ⊩o φ
  A ⊩o (φ1 ∧ φ2) = A ⊩o φ1 × A ⊩o φ2
  A ⊩o (φ1 ∨ φ2) = Either (A ⊩o φ1) (A ⊩o φ2)
  A ⊩o ⊤ = Unit
  A ⊩o ⊥ = Void
-}

  _⊩o_false : ∀ {oc Σ} → Structure oc Σ → Formula Σ → Type
  A ⊩o φ false = A ⊩o (φ *)

-- uformula with ubranches, eform with ebranch, or rel cases
  -- raw game tree that is compatible with the formula
  _⊩s_ : ∀ {oc Σ} → Structure oc Σ → Formula Σ → Type
  A ⊩s ∀i τ φ = Σ \ (bs : List (Branch A Open (i τ))) → (∀ {bi} → bi ∈ bs → extend A bi ⊩s φ) --help! open?
  A ⊩s ∃i τ φ = Σ \ (bs : List (Branch A Closed (i τ))) → (∀ {bi} → bi ∈ bs → extend A bi ⊩s φ) --closed?
  A ⊩s ∀p τ φ = Σ \ (bs : List (Branch A Open (r (τ :: [])))) → (∀ {bi} → bi ∈ bs → extend {_} {Open} A bi ⊩s φ) --closed?
  A ⊩s ∃p τ φ = Σ \ (bs : List (Branch A Open (r (τ :: [])))) → (∀ {bi} → bi ∈ bs → extend {_} {Open} A bi ⊩s φ) --closed?
  A ⊩s (φ1 ∧ φ2) = Either (A ⊩s φ1 × A ⊩s φ2) (Either (A ⊩s φ1) (A ⊩s φ2))
  A ⊩s (φ1 ∨ φ2) = Either (A ⊩s φ1 × A ⊩s φ2) (Either (A ⊩s φ1) (A ⊩s φ2))
  A ⊩s ⊤ = Unit
  A ⊩s ⊥ = Void
  A ⊩s (R rel xs) = Unit
  A ⊩s (¬R rel xs) = Unit

  isUndecided : ∀ {Σ} (A : Structure Open Σ) (φ : Formula Σ) → A ⊩s φ → Type
  isUndecided A (∀i τ φ) (bs , ts) =
    -- (1) every extension in bs is reduced
    (∀ {bi} → (i : bi ∈ bs) → isUndecided (extend A bi) φ (ts i)) ×
    -- (2) every extension not in bs is true
    (∀ {bi} → (bi ∈ bs → Void) → (extend A bi) ⊩o φ)
  isUndecided A (∃i τ φ) (bs , ts) =
    -- (1) every extension in bs is reduced
    (∀ {bi} → (i : bi ∈ bs) → isUndecided (extend A bi) φ (ts i)) ×
    -- (2) every extension not in bs is false
    (∀ {bi} → (bi ∈ bs → Void) → (extend A bi) ⊩o φ false)
  isUndecided A (∀p τ φ) (bs , ts) =
    -- (1) every extension in bs is reduced
    (∀ {bi} → (i : bi ∈ bs) → isUndecided (extend A bi) φ (ts i)) ×
    -- (2) every extension not in bs is true
    (∀ {bi} → (bi ∈ bs → Void) → (extend A bi) ⊩o φ)
  isUndecided A (∃p τ φ) (bs , ts) =
    -- (1) every extension in bs is reduced
    (∀ {bi} → (i : bi ∈ bs) → isUndecided (extend A bi) φ (ts i)) ×
    -- (2) every extension not in bs is false
    (∀ {bi} → (bi ∈ bs → Void) → (extend A bi) ⊩o φ false)
  isUndecided A (φ1 ∧ φ2) (Inl (t1 , t2)) = isUndecided A φ1 t1 × isUndecided A φ2 t2
  isUndecided A (φ1 ∧ φ2) (Inr (Inl t)) = isUndecided A φ1 t × A ⊩o φ2
  isUndecided A (φ1 ∧ φ2) (Inr (Inr t)) = A ⊩o φ1 × isUndecided A φ2 t
  isUndecided A (φ1 ∨ φ2) (Inl (t1 , t2)) = isUndecided A φ1 t1 × isUndecided A φ2 t2
  isUndecided A (φ1 ∨ φ2) (Inr (Inl t)) = isUndecided A φ1 t × A ⊩o φ2 false
  isUndecided A (φ1 ∨ φ2) (Inr (Inr t)) = A ⊩o φ1 false × isUndecided A φ2 t
  isUndecided A ⊤ <> = Void -- NOT Unit because we're not supposed to include winnable branches in a reduced game
  isUndecided A ⊥ ()
  isUndecided A (R U vs) <> = getsOpen vs A == None
  isUndecided A (¬R U vs) <> = getsOpen vs A == None

  -- TODO: define equivalence on ⊩s

  fixed : (A1 : Subset) (A2 : Subset) → Type
  fixed A1 A2 = Σ \ (X : Subset) → ((Sub X (A1)) × ( Sub X (A2))) × DecidableSub X

  fixed1 : (A1 : Subset) → Type
  fixed1 A1 = Σ \ (X : Subset) → (Sub X (A1)) × DecidableSub X

  lemma1 : ∀ (A1 : Subset) → fixed1 A1 → fixed A1 A1
  lemma1 A1 (sb , pfs) = sb , (((fst pfs) , (fst pfs)) , (snd pfs))

  positionEquiv' : ∀ {Σ oc1 oc2} (A1 : Structure oc1 Σ) (A2 : Structure oc2 Σ) → fixed (fst A1) (fst A2)  → Type
  positionEquiv' A1 A2 (X , (X⊆A1 ,  X⊆A2) ,  decX )  = positionEquiv A1 A2 X X⊆A1  X⊆A2 decX

  mutual

    gameEquiv : ∀ {Σ} (A1 A2 : Structure Open Σ) (φ : Formula Σ) → A1 ⊩s φ → A2 ⊩s φ → fixed (fst A1) (fst A2) → Type --f didn't have the same type but it worked??
    gameEquiv A1 A2 φ g1 g2 f =  positionEquiv' A1 A2 f × gameEquiv' A1 A2 φ g1 g2 f

    gameEquiv' : ∀ {Σ} (A1 A2 : Structure Open Σ) (φ : Formula Σ) → A1 ⊩s φ → A2 ⊩s φ → fixed (fst A1) (fst A2) → Type
    gameEquiv' A1 A2 (∀i τ φ) g1 g2 f = Σ (λ (b : ListBijection (fst g1) (fst g2)) → ∀ bi (x : bi ∈ fst g1)
                                             → gameEquiv (extend A1 bi) (extend A2 (fst (fst b (bi , x)))) φ (snd g1 x) (snd g2 (snd (fst b (bi , x)))) f) --need notion of bijection between two lists; define this to be bijection between membership types
    gameEquiv' A1 A2 (∃i τ φ) g1 g2 f = Σ (λ (b : ListBijection (fst g1) (fst g2)) →
                                             ∀ bi (x : bi ∈ fst g1) →
                                             gameEquiv (extend A1 bi) (extend A2 (fst (fst b (bi , x)))) φ (snd g1 x) (snd g2 (snd (fst b (bi , x)))) f)
    gameEquiv' A1 A2 (∀p τ φ) g1 g2 f = Σ (λ (b : ListBijection (fst g1) (fst g2)) →
                                             ∀ bi (x : bi ∈ fst g1) →
                                             gameEquiv (extend A1 bi) (extend A2 (fst (fst b (bi , x)))) φ
                                             (snd g1 x) (snd g2 (snd (fst b (bi , x)))) f)
    gameEquiv' A1 A2 (∃p τ φ) g1 g2 f = Σ (λ (b : ListBijection (fst g1) (fst g2)) →
                                             ∀ bi (x : bi ∈ fst g1) →
                                             gameEquiv (extend A1 bi) (extend A2 (fst (fst b (bi , x)))) φ
                                             (snd g1 x) (snd g2 (snd (fst b (bi , x)))) f)
    gameEquiv' A1 A2 (φ1 ∧ φ2) (Inl (prod1)) (Inl prod2) f = gameEquiv A1 A2 φ1 (fst prod1) (fst prod2) f  ×
                                                                  gameEquiv A1 A2 φ2 (snd prod1) (snd prod2) f
    gameEquiv' A1 A2 (φ1 ∧ φ2) (Inl (A1p1 , A1p2)) (Inr x) f = Void
    gameEquiv' A1 A2 (φ1 ∧ φ2) (Inr g1) (Inl x) f = Void
    gameEquiv' A1 A2 (φ1 ∧ φ2) (Inr (Inl A1p1)) (Inr (Inl A2p1)) f = gameEquiv A1 A2 φ1 A1p1 A2p1 f
    gameEquiv' A1 A2 (φ1 ∧ φ2) (Inr (Inl A1p1)) (Inr (Inr A2p2)) f = Void
    gameEquiv' A1 A2 (φ1 ∧ φ2) (Inr (Inr A1p2)) (Inr (Inl A2p1)) f = Void
    gameEquiv' A1 A2 (φ1 ∧ φ2) (Inr (Inr A1p2)) (Inr (Inr A2p2)) f = gameEquiv A1 A2 φ2 A1p2 A2p2 f
    gameEquiv' A1 A2 (φ1 ∨ φ2) (Inl prod11) (Inl prod22)  f = gameEquiv A1 A2 φ1 (fst prod11) (fst prod22) f  ×
                                                                  gameEquiv A1 A2 φ2 (snd prod11) (snd prod22) f
    gameEquiv' A1 A2 (φ1 ∨ φ2) (Inl x) (Inr g2) f  = Void
    gameEquiv' A1 A2 (φ1 ∨ φ2) (Inr g1) (Inl x) f = Void
    gameEquiv' A1 A2 (φ1 ∨ φ2) (Inr (Inl A1p1)) (Inr (Inl A2p1)) f = gameEquiv A1 A2 φ1 A1p1 A2p1 f
    gameEquiv' A1 A2 (φ1 ∨ φ2) (Inr (Inl A1p1)) (Inr (Inr A2p2)) f = Void
    gameEquiv' A1 A2 (φ1 ∨ φ2) (Inr (Inr A1p2)) (Inr (Inl A2p1)) f = Void
    gameEquiv' A1 A2 (φ1 ∨ φ2) (Inr (Inr A1p2)) (Inr (Inr A2p2)) f = gameEquiv A1 A2 φ2 A1p2 A2p2 f
    gameEquiv' A1 A2 ⊤ g1 g2 f = Unit
    gameEquiv' A1 A2 ⊥ () g2 f
    gameEquiv' A1 A2 (R x x₁) g1 g2 f  = Unit --Unit because the recursive games are unit because relations are at the end of the game tree
    gameEquiv' A1 A2 (¬R x x₁) g1 g2 f = Unit

  -- do everything but foralls and exists in agda; look at for alls and exists on paper and
  --- bijection between two lists of branches --> what information do we need given a bijection from the previous step
  ---given a bijection between the branches, what else do we need to get an equivalence between

  --relation branches are a unit cross an Individs because MSO, relation variables are a list type with one thing in it!
  --bi ∈ bs is enough if conjecture: any two reduced games for A ⊩s φ are equivalent (CHECK!!!!)
    isReduced : ∀ {Σ} (A : Structure Open Σ) (φ : Formula Σ) → A ⊩s φ → (X : fixed1 (fst A)) → Type --(this should be type not function,evidence that game is reduced)  right below here: this is a forall but its (by conjecture) a forall for a singleton
    isReduced A (∀i τ φ) game X = (bi : Maybe (IndividS (fst A) τ)) →
                                 Either (bi ∈ fst game) (Either (extend A bi ⊩o φ) (Σ (λ bj → Σ \ (pfj : bj ∈ fst game) → ((gi : extend A bi ⊩s φ)
                                   → isReduced (extend A bi) φ gi X → gameEquiv (extend A bi) (extend A bj) φ gi (snd game pfj) (lemma1 _ X)))))
    isReduced A (∃i τ φ) game X = (bi : (IndividS (fst A) τ)) →
                                    Either (bi ∈ fst game) (Either (extend A bi ⊩o φ false) (Σ (λ bj → Σ (λ (pfj : bj ∈ fst game) → (gi : extend A bi ⊩s φ) →
                                            isReduced (extend A bi) φ gi X →
                                            gameEquiv (extend A bi) (extend A bj) φ gi (snd game pfj)
                                            (lemma1 _ X)))))
    isReduced A (∀p τ φ) game X = (bi : Unit × IndividS (fst A) τ → Type) → Either (bi ∈ fst game) (Either (extend A bi ⊩o φ)
                                     (Σ (λ bj → Σ (λ (pfj : bj ∈ fst game) → (gi : extend A bi ⊩s φ) → isReduced (extend A bi) φ gi X →
                                            gameEquiv (extend A bi) (extend A bj) φ gi (snd game pfj)
                                            (lemma1 _ X)))))
    isReduced A (∃p τ φ) game X = (bi : Unit × IndividS (fst A) τ → Type) → Either (bi ∈ fst game) (Either (extend A bi ⊩o φ false)
                                     (Σ (λ bj → Σ (λ (pfj : bj ∈ fst game) → (gi : extend A bi ⊩s φ) → isReduced (extend A bi) φ gi X →
                                            gameEquiv (extend A bi) (extend A bj) φ gi (snd game pfj)
                                            (lemma1 _ X)))))
    isReduced A (φ1 ∧ φ2) (Inl x) X = isReduced A φ1 (fst x) X × isReduced A φ2 (snd x) X
    isReduced A (φ1 ∧ φ2) (Inr (Inl x)) X = isReduced A φ1 x X × A ⊩o φ2
    isReduced A (φ1 ∧ φ2) (Inr (Inr x)) X = A ⊩o φ1 × isReduced A φ2 x X
    isReduced A (φ1 ∨ φ2) (Inl x) X = isReduced A φ1 (fst x) X × isReduced A φ2 (snd x) X
    isReduced A (φ1 ∨ φ2) (Inr (Inl x)) X = isReduced A φ1 x X × A ⊩o φ2 false
    isReduced A (φ1 ∨ φ2) (Inr (Inr x)) X = A ⊩o φ1 false × isReduced A φ2 x X
    isReduced A ⊤ game X = Unit
    isReduced A ⊥ () X
    isReduced A (R x x₁) game X = Unit
    isReduced A (¬R x x₁) game X = Unit


  -- naive : ∀ {Σ φ} {A : Structure Closed Σ} → Either (A ⊩c φ) (A ⊩c φ false)
  -- naive = {!!}

--naive algorithm to work on the restricted bags... this is what we had on the board but I feel very wrong about this
 --postulate
--    naive : ∀ {Σ} → (φ : Formula Σ) (A : Structure Closed Σ) → (game : A ⊩s φ) → (X : fixed1 (fst A)) → Either (Either (A ⊩c φ) (A ⊩c φ false)) (isReduced A φ game X)
 {- naive (∀i τ φ) A = {!!}
  naive (∃i τ φ) A = {!!}
  naive (∀p τ φ) A = {!!}
  naive (∃p τ φ) A = {!!}
  naive (φ ∧ φ₁) A = {!!}
  naive (φ ∨ φ₁) A = {!!}
  naive ⊤ A = Inl <>
  naive ⊥ A = Inr {!!}
  naive (R x x₁) A = {!!}
  naive (¬R x x₁) A = {!!} -}

{-
  introduce : (A : Structure Open Σ) (φ : Formula Σ) (game : A ⊩s φ) (X : fixed1 (fst A)) →
  (xnew : (Sub (singleton {τ = τ} x) (complement X)))
-}
