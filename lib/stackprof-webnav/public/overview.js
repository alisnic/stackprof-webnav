;(function() {
	const table = document.getElementsByTagName('table')[0]
	const input = document.getElementsByClassName('filter')[0]
	const rows = {}
	const filterKeys = Array.from(document.querySelectorAll('tr[data-filter-key]')).map(el => {
		key = el.dataset.filterKey
		rows[key] = el
		return key
	})
	const scores = {}
	const computeScores = () => {
		const searchString = input.value
		filterKeys.forEach(filterKey => scores[filterKey] = stringScore(filterKey, searchString))
	}

	const redrawTable = (sorted) => {
		const newBody = document.createElement('tbody')
		sorted.forEach(key => newBody.appendChild(rows[key]))
		table.removeChild(table.getElementsByTagName('tbody')[0])
		table.appendChild(newBody)
	}

	input.addEventListener('input', () => {
		computeScores()
		redrawTable(
			filterKeys.filter(k => scores[k] !== 0).sort((a, b) => scores[b] - scores[a])
		)
	})
})()
