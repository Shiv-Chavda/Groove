import Joi from 'joi';
import { User, RefreshToken } from '../../models';
import CustomErrorHandler from '../../services/CustomErrorHandler';
import bcrypt from 'bcrypt';
import JwtService from '../../services/JwtService';
import { REFRESH_SECRET, DEBUG_MODE } from '../../config';


const loginController = {
    async login(req, res, next) {
        const isDebug = DEBUG_MODE === 'true' || DEBUG_MODE === '1' || DEBUG_MODE === true;
        if (isDebug) {
            try {
                console.log('[login] incoming request', {
                    ip: req.ip,
                    ua: req.headers['user-agent'],
                    email: req.body && req.body.email,
                    passwordLen: req.body && req.body.password ? req.body.password.length : 0,
                });
            } catch (_) {}
        }
        //Validation
        const loginSchema = Joi.object({
            email: Joi.string().email().required(),
            password: Joi.string().pattern(new RegExp('^[a-zA-Z0-9]{3,30}$')).required(),
            repeat_password: Joi.ref('password')
        });
        const { error } = loginSchema.validate(req.body);
        if(error){
            if (isDebug) {
                console.log('[login] validation error', error.details ? error.details.map(d => d.message) : error.message);
            }
            return next(error);
        }
        try{
            const user = await User.findOne({ email: req.body.email });
            if (!user) {
                if (isDebug) {
                    console.log('[login] user not found', { emailTried: req.body.email });
                }
                return next(CustomErrorHandler.wrongCredentials());
            }
            // compare the password
            const match = await bcrypt.compare(req.body.password, user.password);
            if (!match) {
                if (isDebug) {
                    console.log('[login] wrong password', { userId: String(user._id) });
                }
                return next(CustomErrorHandler.wrongCredentials());
            }
            //Token
            const access_token = JwtService.sign({ _id: user._id, role: user.role });
            
            const refresh_token = JwtService.sign({ _id: user._id, role: user.role }, '1y', REFRESH_SECRET);
            //Database Whitelist

            await RefreshToken.create({ token: refresh_token });
            if (isDebug) {
                const mask = (t) => (t ? `${t.slice(0,12)}...(${t.length})` : '');
                console.log('[login] success', {
                    userId: String(user._id),
                    accessToken: mask(access_token),
                    refreshToken: mask(refresh_token),
                });
            }
            res.json({ access_token, refresh_token });

        } catch(err){
            if (isDebug) {
                console.log('[login] error', { message: err.message, stack: err.stack });
            }
            return next(err);
        }
    },
    async logout(req, res, next) {
        //Validation
        const refreshSchema = Joi.object({
            refresh_token: Joi.string().required(),
            
        });
        const { error } = refreshSchema.validate(req.body);
        if(error){
            return next(error);
        }

        try{
            await RefreshToken.deleteOne({ token: req.body.refresh_token });
        } catch(err){
            return next(new Error('Something went wrong in the database'));
        }
        res.json({ status: 1 });
    }
};
export default loginController;