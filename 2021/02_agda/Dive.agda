{-# OPTIONS --without-K --guardedness #-}

module Dive where

open import Relation.Binary.PropositionalEquality using (_≡_; refl)
open import Data.List using (List; _∷_; []; foldl)
open import Data.Nat using (ℕ)
open import Data.Nat.Show renaming (readMaybe to readℕ)
open import Data.Integer using (ℤ; +_; _+_; _-_; _*_)
open import Data.Integer.Show renaming (show to showⁱ)
open import Data.Maybe using (Maybe; maybe; just; nothing; zip) renaming (_>>=_ to _>>=ᵐ_)
open import Data.String using (String; lines; words; _++_)
open import Data.Product using (_×_; _,_)
open import Function.Base using (_$_; _∘_; id; flip)
open import IO using (IO; Main; run; readFiniteFile; putStrLn) renaming (_>>=_ to _>>=ⁱ_)

data Op : Set where
  forward : Op
  down : Op
  up : Op

Cmd = Op × ℤ
Result = ℤ × ℤ
record State : Set where
  field
    position : ℤ
    depth : ℤ
    aim : ℤ
open State

apply-cmd : Cmd → State → State
apply-cmd (forward , n) record { position = position ; depth = depth ; aim = aim } =
  record { position = position + n ; depth = depth + aim * n ; aim = aim }
apply-cmd (down , n) record { position = position ; depth = depth ; aim = aim } =
  record { position = position ; depth = depth ; aim = aim + n }
apply-cmd (up , n) record { position = position ; depth = depth ; aim = aim } =
  record { position = position ; depth = depth ; aim = aim - n }

to-op : String → Maybe Op
to-op "forward" = just forward
to-op "up" = just up
to-op "down" = just down
to-op _ = nothing

maybe-two-words : String → Maybe (String × String)
maybe-two-words s with words s
... | a ∷ b ∷ [] = just (a , b)
... | _ = nothing

maybe-cmd : String → Maybe Cmd
maybe-cmd str =
  maybe-two-words str >>=ᵐ λ (op-str , x-str) →
  to-op op-str >>=ᵐ λ op →
  readℕ 10 x-str >>=ᵐ λ x →
  just (op , + x)

final-state : List String → State
final-state = foldl (flip (maybe apply-cmd id ∘ maybe-cmd)) record { position = + 0 ; depth = + 0 ; aim = + 0 }

result : String → Result
result s =
  let record { position = position ; depth = depth ; aim = aim } = (final-state ∘ lines) s
  in position * aim , position * depth

showʳ : Result → String
showʳ (fst , snd) = showⁱ fst ++ " " ++ showⁱ snd

_ : result "forward 5\ndown 5\nforward 8\nup 3\ndown 8\nforward 2" ≡ (+ 150 , + 900)
_ = refl

main : Main
main = run $ readFiniteFile "input.txt" >>=ⁱ putStrLn ∘ showʳ ∘ result
