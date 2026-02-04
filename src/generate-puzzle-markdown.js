import { parse } from 'csv-parse/sync';
import { readFileSync, writeFileSync } from 'fs';
import { join, dirname } from 'path';
import { fileURLToPath } from 'url';
import { Chess } from 'chess.js';

const __dirname = dirname(fileURLToPath(import.meta.url));

// Rate limiting delay to avoid Lichess API throttling (in milliseconds)
const API_RATE_LIMIT_DELAY = 500;

// Helper function to parse PGN moves into an array
// Note: This assumes Lichess API PGN format without comments or variations
// which is the standard format returned by the puzzle API
function parsePgnMoves(pgn) {
  // Parse PGN moves (space-separated)
  return pgn.split(/\s+/).filter(move => {
    // Filter out move numbers (e.g., "1.", "2.", etc.)
    return move && !move.match(/^\d+\.+$/);
  });
}

// Function to fetch puzzle data from Lichess API
async function fetchPuzzleData(puzzleId) {
  const response = await fetch(`https://lichess.org/api/puzzle/${puzzleId}`);
  if (!response.ok) {
    throw new Error(`Failed to fetch puzzle ${puzzleId}: ${response.statusText}`);
  }
  return await response.json();
}

// Function to get FEN from PGN at a specific ply
function getFenFromPgn(pgn, plyNumber) {
  const chess = new Chess();
  const moves = parsePgnMoves(pgn);
  
  // Play moves up to the specified ply
  for (let i = 0; i < plyNumber; i++) {
    if (i >= moves.length) break;
    
    try {
      chess.move(moves[i], { sloppy: true });
    } catch (e) {
      console.error(`  Error applying move ${i + 1} (${moves[i]}):`, e.message);
      throw e;
    }
  }
  
  return chess.fen();
}

// Function to get the last move in SAN notation
function getLastMove(pgn, plyNumber) {
  const moves = parsePgnMoves(pgn);
  
  if (plyNumber > 0 && plyNumber <= moves.length) {
    return moves[plyNumber - 1];
  }
  return null;
}

// Function to convert SAN move to UCI format for the lastMove parameter
function getLastMoveUCI(pgn, plyNumber) {
  if (plyNumber === 0) return null;
  
  const chess = new Chess();
  const moves = parsePgnMoves(pgn);
  
  // Play moves up to plyNumber - 1
  for (let i = 0; i < plyNumber - 1; i++) {
    if (i >= moves.length) break;
    chess.move(moves[i], { sloppy: true });
  }
  
  // Get the move at plyNumber
  if (plyNumber - 1 < moves.length) {
    const move = chess.move(moves[plyNumber - 1], { sloppy: true });
    if (move) {
      return `${move.from}${move.to}`;
    }
  }
  
  return null;
}

// Function to construct screenshot URL from FEN
function constructScreenshotUrl(fen, color, lastMove) {
  const encodedFen = encodeURIComponent(fen);
  let url = `https://lichess1.org/export/fen.gif?fen=${encodedFen}&color=${color}`;
  
  if (lastMove) {
    url += `&lastMove=${lastMove}`;
  }
  
  url += '&variant=standard&theme=brown&piece=cburnett';
  
  return url;
}

// Main function
async function generateMarkdown() {
  const csvPath = join(__dirname, '../data/filter/easy-puzzles-failed-today-or-yesterday.csv');
  const outputPath = join(__dirname, '../data/easy-puzzles-failed.md');
  
  console.log('Reading CSV file...');
  const csvContent = readFileSync(csvPath, 'utf-8');
  const records = parse(csvContent, {
    columns: true,
    skip_empty_lines: true
  });
  
  console.log(`Found ${records.length} puzzles`);
  
  // Extract unique puzzle IDs from href column
  const puzzleIds = [...new Set(records.map(record => {
    const href = record.href;
    return href.replace('/training/', '');
  }))];
  
  console.log(`Processing ${puzzleIds.length} unique puzzles`);
  
  let markdown = '# Easy puzzles failed today or yesterday\n\n';
  
  for (const puzzleId of puzzleIds) {
    console.log(`\nProcessing puzzle: ${puzzleId}`);
    
    try {
      // Fetch puzzle data from API
      const puzzleData = await fetchPuzzleData(puzzleId);
      const pgn = puzzleData.game.pgn;
      const initialPly = puzzleData.puzzle.initialPly;
      
      console.log(`  Initial Ply: ${initialPly}`);
      
      // In Lichess puzzles, initialPly represents the position after the opponent's move,
      // but we need to show the position where it's the player's turn (white in puzzle view).
      // Since puzzles show the position where you need to find the move, we use initialPly + 1.
      const fen = getFenFromPgn(pgn, initialPly + 1);
      console.log(`  FEN: ${fen}`);
      
      // In Lichess puzzles, the board is always shown from white's perspective
      // regardless of whose turn it is in the FEN
      const color = 'white';
      
      // Get last move in UCI format (the move that led to this position)
      const lastMove = getLastMoveUCI(pgn, initialPly + 1);
      console.log(`  Last move: ${lastMove || 'none'}`);
      
      // Construct screenshot URL
      const screenshotUrl = constructScreenshotUrl(fen, color, lastMove);
      
      // Add to markdown
      markdown += `## [${puzzleId}](https://lichess.org/training/${puzzleId})\n\n`;
      markdown += `![](${screenshotUrl})\n\n`;
      
      console.log(`  ✓ Added to markdown`);
      
      // Rate limiting to respect Lichess API limits
      await new Promise(resolve => setTimeout(resolve, API_RATE_LIMIT_DELAY));
    } catch (error) {
      console.error(`  ✗ Error processing puzzle ${puzzleId}:`, error.message);
      // Continue with next puzzle
    }
  }
  
  // Write markdown file
  console.log(`\nWriting markdown to: ${outputPath}`);
  writeFileSync(outputPath, markdown);
  console.log('Done!');
}

// Run the script
generateMarkdown().catch(error => {
  console.error('Fatal error:', error);
  process.exit(1);
});
