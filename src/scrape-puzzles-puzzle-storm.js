const runId = crypto.randomUUID();
const now = new Date();
const date = now.toISOString().split('T')[0]; // YYYY-MM-DD
const time = now.toTimeString().split(' ')[0]; // HH:MM:SS in 24-hour format

// Helper function to escape CSV values
const escapeCSV = (value) => {
  if (value == null) return '';
  const str = String(value);
  // Escape if contains comma, quote, newline, or carriage return
  if (str.includes(',') || str.includes('"') || str.includes('\n') || str.includes('\r')) {
    return `"${str.replace(/"/g, '""')}"`;
  }
  return str;
};

console.log(
  Array.from(document.querySelectorAll('.puz-history__round')).map(round => {
    const resultElement = round.querySelector('good') || round.querySelector('bad');
    const rating = parseInt(round.querySelector('rating').textContent);
    const href = round.querySelector('a').getAttribute('href');
    const result = round.querySelector('good') ? 'good' : 'bad';
    const clock = parseInt(resultElement.textContent);
    return `${escapeCSV(runId)},${escapeCSV(date)},${escapeCSV(time)},${escapeCSV(rating)},${escapeCSV(href)},${escapeCSV(result)},${escapeCSV(clock)}`;
  }).join('\n')
)
