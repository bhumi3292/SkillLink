const multer = require("multer");
const path = require("path");

const storage = multer.diskStorage({
    destination: (req, file, cb) => {
        cb(null, "uploads/");
    },
    filename: (req, file, cb) => {
        // Create a unique filename to prevent conflicts
        const uniqueSuffix = Date.now() + "-" + Math.round(Math.random() * 1e9);
        const fileExtension = path.extname(file.originalname);
        cb(null, file.fieldname + "-" + uniqueSuffix + fileExtension);
    },
});

const allowedMimeTypes = ["image/jpeg", "image/png", "image/gif", "video/mp4", "video/quicktime", "video/webm", "application/pdf"];

const upload = multer({
    storage,
    fileFilter: (req, file, cb) => {
        if (allowedMimeTypes.includes(file.mimetype)) {
            cb(null, true);
        } else {
            cb(new Error("Unsupported file type!"), false);
        }
    },
    limits: {
        fileSize: 100 * 1024 * 1024,
    },
});

const uploadWorkerMedia = upload.fields([
    { name: "images", maxCount: 10 },
    { name: "videos", maxCount: 3 },
    { name: "license", maxCount: 1 },
    { name: "identityCard", maxCount: 1 },
]);

module.exports = uploadWorkerMedia;
