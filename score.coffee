###!
 * string_score.js: Quicksilver-like string scoring algorithm.
 *
 * Copyright (C) 2009 Joshaven Potter <yourtech@gmail.com>
 * Copyright (C) 2010 Yesudeep Mangalapilly <yesudeep@gmail.com>
 * Licensed under the MIT license.
 * http://www.opensource.org/licenses/mit-license.php
 ###

# Special thanks to Lachie Cox and Quicksilver for inspiration.
#
# Compilation notes:
# 1. Compile with the -b -c flags to the coffee-script compiler

String::score = (abbreviation) ->
    
    # Perfect match if the string equals the abbreviation.
    return 1.0 if this == abbreviation

    # Initialization.
    string = this
    string_length = string.length
    should_award_common_prefix_bonus = 0 #no        # Only if the string and the abbreviation have a common prefix
    total_character_score = 0
    
    # Add up scores for each character in the abbreviation
    for c, i in abbreviation
        # Find the index of current character (case-insensitive) in remaining part of string.
        index_c_lowercase = string.indexOf c.toLowerCase()
        index_c_uppercase = string.indexOf c.toUpperCase()
        min_index = Math.min index_c_lowercase, index_c_uppercase
        index_in_string = if min_index > -1 then min_index else Math.max index_c_lowercase, index_c_uppercase        

        # Bail out if current character is not found (case-insensitive) in remaining part of string.
        return 0 if index_in_string == -1
        
        # Set base score for current character
        character_score = 0.1
        
        # Same case bonus
        if string[index_in_string] == c
            character_score += 0.1
        
        if index_in_string == 0
            # Increase the score when each consecutive character of
            # the abbreviation matches the first character of the 
            # remaining string.
            character_score += 0.8
            if i == 0
                # String and abbreviation have common prefix, so award bonus. 
                should_award_common_prefix_bonus = 1 #yes
        
        # Acronym bonus
        #
        # Rationale:
        # Typing the first character of an acronym is as
        # though you preceded it with two perfect character
        # matches.
        if string[index_in_string - 1] == ' '
            character_score += 0.8 # * Math.min(index_in_string, 5) # Cap bonus at 0.4 * 5
        
        # Left trim the matched part of the string
        # (forces sequential matching).
        string = string.substring(index_in_string + 1, string_length)
 
        # Sum character score.
        total_character_score += character_score
    
    # Uncomment to weigh smaller words higher.
    # return total_character_score / string_length
    
    abbreviation_length = abbreviation.length
    abbreviation_score = total_character_score / abbreviation_length
    percentage_of_matched_string = abbreviation_length / string_length
    word_score = abbreviation_score * percentage_of_matched_string
    
    # Reduce penalty for longer strings.
    final_score = (word_score + abbreviation_score) / 2
    
    if should_award_common_prefix_bonus and (final_score + 0.1 < 1)
        final_score += 0.1
    
    return final_score
