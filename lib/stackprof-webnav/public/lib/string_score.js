/*
 * string_score.js: Quicksilver-like string scoring algorithm.
 *
 * Copyright (C) 2009-2011 Joshaven Potter <yourtech@gmail.com>
 * Copyright (C) 2010-2011 Yesudeep Mangalapilly <yesudeep@gmail.com>
 * MIT license: http://www.opensource.org/licenses/mit-license.php
 *
 * This is a javascript port of the above mentionned, with a tiny change:
 * it avoids string monkey patch.
 */
;(function(global) {
	global.string_score = (string, abbreviation) => {
		// Perfect match if the spring equals the abbreviation
		if (string == abbreviation) return 1.0

		// Initializing variables.
		let string_length = string.length
		let abbreviation_length = abbreviation.length
		let total_character_score = 0

		// Awarded only if the string and the abbreviation have a common prefix.
		let should_award_common_prefix_bonus = 0

		// # Sum character scores

		// Add up scores for each character in the abbreviation.
		for (let i = 0, c = abbreviation[i]; i < abbreviation_length; c = abbreviation[++i]) {
			// Find the index of current character (case-insensitive) in remaining part of string.
        	let index_c_lowercase = string.indexOf(c.toLowerCase())
        	let index_c_uppercase = string.indexOf(c.toUpperCase())
        	let min_index = Math.min(index_c_lowercase, index_c_uppercase)
        	let index_in_string = min_index > -1 ? min_index : Math.max(index_c_lowercase, index_c_uppercase)

			// # Identical Strings
			// Bail out if current character is not found (case-insensitive) in remaining part of string.
			if (index_in_string == -1) return 0

			// Set base score for current character.
			let character_score = 0.1


			// # Case-match bonus
			// If the current abbreviation character has the same case
			// as that of the character in the string, we add a bonus.
			if (string[index_in_string] == c) character_score += 0.1

			// # Consecutive character match and common prefix bonuses
			// Increase the score when each consecutive character of
			// the abbreviation matches the first character of the
			// remaining string.
			if (index_in_string == 0) {
				character_score += 0.8
				// String and abbreviation have common prefix, so award bonus.
				if (i == 0) should_award_common_prefix_bonus = 1
			}

			// # Acronym bonus
			// Typing the first character of an acronym is as
			// though you preceded it with two perfect character
			// matches.
			if (string.charAt(index_in_string - 1) == ' ') // TODO: better accro
				character_score += 0.8 // * Math.min(index_in_string, 5) # Cap bonus at 0.4 * 5

			// Left trim the matched part of the string
			// (forces sequential matching).
			string = string.substring(index_in_string + 1, string_length)

			// Add to total character score.
			total_character_score += character_score
		}

		let abbreviation_score = total_character_score / abbreviation_length

		let final_score = ((abbreviation_score * (abbreviation_length / string_length)) + abbreviation_score) / 2
		if (should_award_common_prefix_bonus && final_score + 0.1 < 1) final_score += 0.1
		return final_score
	}
})(window)
