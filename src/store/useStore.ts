import { create } from 'zustand';
import { persist } from 'zustand/middleware';

export interface Product {
  id: string;
  name: string;
  description: string | null;
  price: number;
  category_id: string | null;
  images: string[];
  specifications: Record<string, any>;
  stock_quantity: number;
  is_featured: boolean;
  created_at: string;
  updated_at: string;
  categories?: {
    id: string;
    name: string;
    description: string;
  };
}

export interface Category {
  id: string;
  name: string;
  description: string | null;
  image_url: string | null;
  created_at: string;
}

export interface CartItem {
  product: Product;
  quantity: number;
}

export interface User {
  id: string;
  email: string;
}

interface Store {
  // User state
  user: User | null;
  setUser: (user: User | null) => void;
  
  // Cart state
  cart: CartItem[];
  addToCart: (product: Product, quantity?: number) => void;
  removeFromCart: (productId: string) => void;
  updateCartQuantity: (productId: string, quantity: number) => void;
  clearCart: () => void;
  
  // UI state
  isCartOpen: boolean;
  setCartOpen: (open: boolean) => void;
  currentCategory: string | null;
  setCurrentCategory: (categoryId: string | null) => void;
}

export const useStore = create<Store>()(
  persist(
    (set, get) => ({
      // User state
      user: null,
      setUser: (user) => set({ user }),
      
      // Cart state
      cart: [],
      addToCart: (product, quantity = 1) => {
        const { cart } = get();
        const existingItem = cart.find(item => item.product.id === product.id);
        
        if (existingItem) {
          set({
            cart: cart.map(item =>
              item.product.id === product.id
                ? { ...item, quantity: item.quantity + quantity }
                : item
            )
          });
        } else {
          set({ cart: [...cart, { product, quantity }] });
        }
      },
      
      removeFromCart: (productId) => {
        set({
          cart: get().cart.filter(item => item.product.id !== productId)
        });
      },
      
      updateCartQuantity: (productId, quantity) => {
        if (quantity <= 0) {
          get().removeFromCart(productId);
          return;
        }
        
        set({
          cart: get().cart.map(item =>
            item.product.id === productId
              ? { ...item, quantity }
              : item
          )
        });
      },
      
      clearCart: () => set({ cart: [] }),
      
      // UI state
      isCartOpen: false,
      setCartOpen: (open) => set({ isCartOpen: open }),
      currentCategory: null,
      setCurrentCategory: (categoryId) => set({ currentCategory: categoryId }),
    }),
    {
      name: 'coolie-store',
      partialize: (state) => ({
        cart: state.cart,
        user: state.user,
      }),
    }
  )
);