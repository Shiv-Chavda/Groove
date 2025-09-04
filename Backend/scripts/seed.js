import mongoose from 'mongoose';
import path from 'path';
import fs from 'fs';
import { DB_URL } from '../config';
import Music from '../models/music';
import { parse } from 'csv-parse';

async function main() {
  console.log('[seed] connecting to', DB_URL);
  await mongoose.connect(DB_URL, { useNewUrlParser: true, useUnifiedTopology: true });
  console.log('[seed] connected');

  const projectRoot = process.cwd();
  const csvPath = path.join(projectRoot, 'high_popularity_spotify_data.csv');
  const musicDir = path.resolve(path.join(projectRoot, 'music'));

  const docs = [];

  if (fs.existsSync(csvPath)) {
    console.log('[seed] CSV detected at', csvPath, '— parsing...');
    const csvRaw = fs.readFileSync(csvPath, 'utf8');
    const records = await new Promise((resolve, reject) => {
      parse(csvRaw, { columns: true, skip_empty_lines: true }, (err, output) => {
        if (err) return reject(err);
        resolve(output);
      });
    });
    // Map CSV rows to Music documents. Make reasonable mapping assumptions:
    // - track_name -> title
    // - track_artist -> authors
    // - track_popularity -> rating (scale 0-100 -> 1-5)
    // - playlist_genre or playlist_subgenre -> genre
    // - track_id or id -> used as unique id field for audio filename if available
    // Note: audio files are not included in CSV. We'll set audio/thumbnail paths to empty
    // user should download actual media into music/ and update paths if needed.
    // Prepare music directory file list and sensible defaults once
    let files = [];
    let jpgs = [];
    let mp3s = [];
    let defaultAudio = '';
    let defaultThumb = '';
    if (fs.existsSync(musicDir)) {
      files = fs.readdirSync(musicDir);
      jpgs = files.filter(f => f.toLowerCase().endsWith('.jpg'));
      mp3s = files.filter(f => f.toLowerCase().endsWith('.mp3'));
      const firstMp3 = mp3s[0] || '';
      const firstJpg = jpgs[0] || '';
      if (firstMp3) defaultAudio = path.join('music', firstMp3);
      if (firstJpg) defaultThumb = path.join('music', firstJpg);
    }

    for (let idx = 0; idx < records.length; idx++) {
      const row = records[idx];
      const title = row.track_name || row.track_album_name || 'Unknown';
      const authors = row.track_artist || 'Unknown';
      const popularity = parseInt(row.track_popularity || row.track_popularity || '0', 10) || 0;
      // Map 0-100 popularity to 1-5 rating
      const rating = Math.max(1, Math.min(5, Math.round((popularity / 100) * 5)));
      const genre = row.playlist_genre || row.playlist_subgenre || 'Unknown';
      const trackId = row.track_id || row.id || '';

      // Attempt to find media files in music/ matching the track id or track name
      let audioPath = '';
      let thumb = '';
      if (files.length > 0) {
        // find mp3 that contains trackId or track name
        const mp3 = mp3s.find(f => ((trackId && f.includes(trackId)) || f.toLowerCase().includes((title || '').toLowerCase().replace(/\s+/g, ''))));
        if (mp3) audioPath = path.join('music', mp3);
        const jpg = jpgs.find(f => ((trackId && f.includes(trackId)) || f.toLowerCase().includes((title || '').toLowerCase().replace(/\s+/g, ''))));
        if (jpg) thumb = path.join('music', jpg);
      }

      // fallbacks to available media so required fields are not empty
      if (!audioPath && defaultAudio) {
        // distribute audio across available files for variety
        if (mp3s.length > 0) {
          const pick = mp3s[idx % mp3s.length];
          audioPath = path.join('music', pick);
        } else {
          audioPath = defaultAudio;
        }
      }
      if (!thumb && defaultThumb) {
        // cycle through available jpgs to avoid the same image everywhere
        if (jpgs.length > 0) {
          const pick = jpgs[idx % jpgs.length];
          thumb = path.join('music', pick);
        } else {
          thumb = defaultThumb;
        }
      }

      docs.push({
        title,
        authors,
        rating,
        genre,
        thumbnail: thumb,
        // Use a different cover by offsetting the index when possible
        thumbnailCover: (jpgs.length > 1)
          ? path.join('music', jpgs[(idx + 1) % jpgs.length])
          : thumb,
        audio: audioPath,
        likes: [],
        recommend: Math.random() > 0.5,
      });
    }

    console.log('[seed] parsed', docs.length, 'rows from CSV');
  } else {
    // fallback: previous directory-scanning behavior
    if (!fs.existsSync(musicDir)) {
      console.log('[seed] no music directory found at', musicDir);
      await mongoose.disconnect();
      return;
    }
    const files = fs.readdirSync(musicDir);
    const mp3s = files.filter(f => f.toLowerCase().endsWith('.mp3'));
    if (mp3s.length === 0) {
      console.log('[seed] no mp3 files found under', musicDir);
      await mongoose.disconnect();
      return;
    }

    for (const audio of mp3s) {
      const prefix = audio.split('.')[0].split('-')[0];
      const thumbs = files.filter(f => f.startsWith(prefix) && f.toLowerCase().endsWith('.jpg'));
      const [thumb, cover] = [thumbs[0], thumbs[1] || thumbs[0]];

      const title = path.basename(audio, path.extname(audio));
      const rating = Math.floor(Math.random() * 5) + 1;
      const genres = ['Pop','Rock','Hip-Hop','Jazz','Classical'];
      const genre = genres[Math.floor(Math.random()*genres.length)];

      docs.push({
        title,
        authors: 'Unknown',
        rating,
        genre,
        thumbnail: path.join('music', thumb || ''),
        thumbnailCover: path.join('music', cover || ''),
        audio: path.join('music', audio),
        likes: [],
        recommend: Math.random() > 0.5,
      });
    }
  }

  if (docs.length === 0) {
    console.log('[seed] no documents prepared');
    await mongoose.disconnect();
    return;
  }

  // wipe existing
  await Music.deleteMany({});
  const inserted = await Music.insertMany(docs);
  console.log('[seed] inserted', inserted.length, 'tracks');
  await mongoose.disconnect();
}

main().catch(err => {
  console.error('[seed] error', err);
  process.exit(1);
});
