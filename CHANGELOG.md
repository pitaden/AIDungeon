# Changelog
Changes to this AIDungeon mod, and their dates, will be added here. If I remember to do that.

## 12/19/2019

### Added
- This newer changelog!
- Backport of random scenarios/characters, with player-chosen names
- Many Sci-fi scenarios, based on SS13
- Additional Fantasy scenarios

### Fixed
- Crashing due to deleting a variable in UnconstrainedStoryManager that it shouldn't be deleting
- Weird and (seemingly) uneccessary grammar changes in the generator (like "words." to "words".

### Changed
- Generator temperature reduced from 0.4 to 0.3
- "You" is no longer prepended to actions. You can now control other characters through actions like "The orcs swings their axe"
- Combined the blocks for `install.sh` and `download.sh` into one block. Why were they even separated?!
- Minor formatting changes in colab
- The order of fantasy scenarios now shows more "common" scenarios at the top, like wizard/knight, with less common ones towards the bottom

### Future Plans
- Reformat the code in `play.py` to make it less of a pain to read and modify
