import Test.QuickCheck
import Test.QuickCheck.Classes
import Test.QuickCheck.Checkers

import Data.List


data Gro n = Gro { fall :: n , grow :: n } deriving (Show, Eq)

wrap d = if d < 0 then Gro (-d) 0 else Gro 0 d

instance (Num n, Ord n) => Semigroup (Gro n) where
    a <> b = Gro (fall a + fall x)
                 (grow b + grow x)
      where
        x = wrap (grow a - fall b) -- x = canonical (fall b) (grow a)

instance (Num n, Ord n) => Monoid (Gro n) where
    mempty = Gro 0 0

grosum :: (Num n, Ord n) => [n] -> n
grosum = grow . foldMap wrap


x ⊞ y = max 0 (x + y)

spec :: [Integer] -> Integer
spec = foldl' (⊞) 0

prop_eq :: [Integer] -> Bool
prop_eq xs = spec xs == grosum xs

prop_monoid = monoid (mempty :: Gro Integer)

main :: IO ()
main = 
    quickCheck prop_eq
    --quickBatch prop_monoid

instance (Num a, Ord a, Arbitrary a) => Arbitrary (Gro a) where
   arbitrary = do
     x <- arbitrary
     return $ wrap x

instance (Num a, Eq a, EqProp a) => EqProp (Gro a) where
    (=-=) = eq
