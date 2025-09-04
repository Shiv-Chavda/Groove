import { Music } from "../models";
import multer from "multer";
import path from "path";
import fs from "fs";
import CustomErrorHandler from "../services/CustomErrorHandler";
import musicSchema from "../validators/musicValidator";
import Joi from "joi";
import { DEBUG_MODE } from "../config";

const isDebug = DEBUG_MODE === "true" || DEBUG_MODE === "1" || DEBUG_MODE === true;
const storage = multer.diskStorage({
  destination: (req, file, cb) => cb(null, "music/"),
  filename: (req, file, cb) => {
    if (file.fieldname === "thumbnail") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
    if (file.fieldname === "thumbnailCover") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
    if (file.fieldname === "audio") {
      const uniqueName = `${Date.now()}-${Math.round(
        Math.random() * 1e9
      )}${path.extname(file.originalname)}`;
      cb(null, uniqueName);
    }
  },
});
const handleMultipartData = multer({
  storage,
  limits: { fileSize: 10000000 * 10 },
}).fields([
  {
    name: "thumbnail",
    maxCount: 1,
  },
  {
    name: "thumbnailCover",
    maxCount: 1,
  },
  {
    name: "audio",
    maxCount: 1,
  },
]); // 100MB

const musicController = {
  async storeMusic(req, res, next) {
    handleMultipartData(req, res, async (err) => {
      if (err) {
        if (isDebug) {
          console.log("[music.store] multer error", { message: err.message });
        }
        return next(CustomErrorHandler.serverError(err.message));
      }
      const thumbnailPath = req.files.thumbnail[0].path;
      const thumbnailCoverPath = req.files.thumbnailCover[0].path;
      const audioPath = req.files.audio[0].path;
      if (isDebug) {
        try {
          console.log("[music.store] incoming", {
            ip: req.ip,
            ua: req.headers["user-agent"],
            body: {
              title: req.body.title,
              authors: req.body.authors,
              rating: req.body.rating,
              genre: req.body.genre,
              recommend: req.body.recommend,
            },
            files: {
              thumbnail: thumbnailPath,
              thumbnailCover: thumbnailCoverPath,
              audio: audioPath,
            },
          });
        } catch (_) {}
      }
      // Validation
      const { error } = musicSchema.validate(req.body);

      if (error) {
        if (isDebug) {
          console.log("[music.store] validation error", error.details ? error.details.map((d) => d.message) : error.message);
        }
        // Delete Thumbnail
        fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });
        // Delete Thumbnail Cover
        fs.unlink(`${appRoot}/${thumbnailCoverPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });
        // Delete Audio
        fs.unlink(`${appRoot}/${audioPath}`, (err) => {
          if (err) {
            return next(CustomErrorHandler.serverError(err.message));
          }
        });

        return next(error);
      }

      const { title, authors, rating, genre, recommend } = req.body;

      let document;
      try {
        document = await Music.create({
          title: title,
          authors: authors,
          rating: rating,
          genre: genre,
          thumbnail: thumbnailPath,
          thumbnailCover: thumbnailCoverPath,
          audio: audioPath,
          likes: [],
          recommend: recommend,
        });
      } catch (err) {
        if (isDebug) {
          console.log("[music.store] db error", { message: err.message });
        }
        return next(err);
      }
      if (isDebug) {
        console.log("[music.store] created", { id: String(document._id) });
      }
      res.status(201).json(document);
    });
  },

  async updateMusic(req, res, next) {
    handleMultipartData(req, res, async (err) => {
      if (err) {
        if (isDebug) {
          console.log("[music.update] multer error", { message: err.message });
        }
        return next(CustomErrorHandler.serverError(err.message));
      }

      let thumbnailPath, thumbnailCoverPath, audioPath;
      if (req.files.thumbnail) {
        thumbnailPath = req.files.thumbnail[0].path;
      }
      if (req.files.thumbnailCover) {
        thumbnailCoverPath = req.files.thumbnailCover[0].path;
      }
      if (req.files.audio) {
        audioPath = req.files.audio[0].path;
      }
      if (isDebug) {
        try {
          console.log("[music.update] incoming", {
            params: { musicId: req.params.musicId },
            body: {
              title: req.body.title,
              authors: req.body.authors,
              rating: req.body.rating,
              genre: req.body.genre,
              recommend: req.body.recommend,
            },
            files: {
              thumbnail: thumbnailPath,
              thumbnailCover: thumbnailCoverPath,
              audio: audioPath,
            },
          });
        } catch (_) {}
      }

      //Validation
      const { error } = musicSchema.validate(req.body);
      if (error) {
        if (isDebug) {
          console.log("[music.update] validation error", error.details ? error.details.map((d) => d.message) : error.message);
        }
        // Delete Thumbnail
        if (req.files.thumbnail) {
          fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
            if (err) {
              return next(CustomErrorHandler.serverError(err.message));
            }
          });
        }
        // Delete Thumbnail Cover
        if (req.files.thumbnailCover) {
          fs.unlink(`${appRoot}/${thumbnailCoverPath}`, (err) => {
            if (err) {
              return next(CustomErrorHandler.serverError(err.message));
            }
          });
        }
        // Delete Audio
        if (req.files.audio) {
          fs.unlink(`${appRoot}/${audioPath}`, (err) => {
            if (err) {
              return next(CustomErrorHandler.serverError(err.message));
            }
          });
        }

        return next(error);
      }

      const { title, authors, rating, genre, recommend } = req.body;
      let document;
      try {
        document = await Music.findOneAndUpdate(
          { _id: req.params.musicId },
          {
            title: title,
            authors: authors,
            rating: rating,
            genre: genre,
            ...(req.files.thumbnail && { thumbnail: thumbnailPath }),
            ...(req.files.thumbnailCover && {
              thumbnailCover: thumbnailCoverPath,
            }),
            ...(req.files.audio && { audio: audioPath }),
            recommend: recommend,
          },
          { new: true }
        );
      } catch (err) {
        if (isDebug) {
          console.log("[music.update] db error", { message: err.message });
        }
        return next(err);
      }
      if (isDebug) {
    console.log("[music.update] updated", { id: document ? String(document._id) : null });
      }
      res.status(201).json(document);
    });
  },

  async deleteMusic(req, res, next) {
    if (isDebug) {
      console.log("[music.delete] request", { params: { musicId: req.params.musicId } });
    }
    const document = await Music.findOneAndRemove({
      _id: req.params.musicId,
    });
    if (!document) {
      if (isDebug) {
        console.log("[music.delete] not found", { params: { musicId: req.params.musicId } });
      }
      return next(new Error("Nothing to delete"));
    }
    const thumbnailPath = document._doc.thumbnail;
    const thumbnailCoverPath = document._doc.thumbnailCover;
    const audioPath = document._doc.audio;
    // Delete Thumbnail
    fs.unlink(`${appRoot}/${thumbnailPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });
    // Delete Thumbnail Cover
    fs.unlink(`${appRoot}/${thumbnailCoverPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });
    // Delete Audio File
    fs.unlink(`${appRoot}/${audioPath}`, (err) => {
      if (err) {
        return next(CustomErrorHandler.serverError());
      }
    });
    if (isDebug) {
      console.log("[music.delete] deleted", { id: String(document._id) });
    }
    res.json(document);
  },

  async getMusic(req, res, next) {
    let documents;
    try {
      documents = await Music.find()
        .select("-updatedAt -__v")
        .sort({ createdAt: -1 });
    } catch (err) {
      return next(CustomErrorHandler.serverError());
    }
    if (isDebug) {
      console.log("[music.list] result", { count: Array.isArray(documents) ? documents.length : 0 });
    }
    return res.json(documents);
  },

  async likeMusic(req, res, next) {
    if (isDebug) {
  console.log("[music.like] request", { params: { musicId: req.params.musicId }, likesCount: (req.body && Array.isArray(req.body.likes)) ? req.body.likes.length : null });
    }
    const likemusicSchema = Joi.object({
      likes: Joi.array().required(),
    });

    const { error } = likemusicSchema.validate(req.body);
    if (error) {
      return next(error);
    }

    const { likes } = req.body;
    //Update Likes
    let document;
    try {
      document = await Music.findOneAndUpdate(
        { _id: req.params.musicId },
        {
          likes: likes,
        },
        { new: true }
      );
    } catch (err) {
      return next(err);
    }
    if (isDebug) {
  console.log("[music.like] updated", { id: document ? String(document._id) : null, likesCount: (document && Array.isArray(document.likes)) ? document.likes.length : null });
    }
    res.status(201).json(document);
  },

  async searchMusic(req, res, next) {
    let document;
    // Support both path param and query param for search
    const titleQuery = (req.query && req.query.q) ? req.query.q : req.params.title;
    if (isDebug) {
      console.log("[music.search] incoming", { params: req.params, query: req.query });
    }
    try {
      document = await Music.find({
        title: { $regex: titleQuery || "", $options: "i" },
      }).select("-updatedAt -__v");
    } catch (err) {
      return next(CustomErrorHandler.serverError());
    }
    if (isDebug) {
      console.log("[music.search] result", { title: titleQuery, count: Array.isArray(document) ? document.length : 0, sample: Array.isArray(document) ? document.slice(0,10).map(d => d.title) : [] });
    }
    return res.json(document);
  },
  async streamingMusic(req, res, next) {
    const audioPath = `music/${req.params.id}`;
    try {
      const audioStat = fs.statSync(audioPath);
      const fileSize = audioStat.size;
      const audioRange = req.headers.range;
      if (audioRange) {
        const parts = audioRange.replace(/bytes=/, "").split("-");
        const start = parseInt(parts[0], 10);
        const end = parts[1] ? parseInt(parts[1], 10) : fileSize - 1;
        const chunksize = end - start + 1;
        if (isDebug) {
          console.log("[music.stream] partial", { path: audioPath, start, end, chunksize, fileSize });
        }
        const file = fs.createReadStream(audioPath, { start, end });
        const head = {
          "Content-Range": `bytes ${start}-${end}/${fileSize}`,
          "Accept-Ranges": "bytes",
          "Content-Length": chunksize,
          "Content-Type": "audio/mpeg",
        };
        res.writeHead(206, head);
        file.pipe(res);
      } else {
        if (isDebug) {
          console.log("[music.stream] full", { path: audioPath, fileSize });
        }
        const head = {
          "Content-Length": fileSize,
          "Content-Type": "audio/mpeg",
        };
        res.writeHead(200, head);
        fs.createReadStream(audioPath).pipe(res);
      }
    } catch (err) {
      if (isDebug) {
        console.log("[music.stream] error", { path: audioPath, message: err.message });
      }
      return next(CustomErrorHandler.serverError());
    }
  },
};
export default musicController;
