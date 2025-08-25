import { useState, useEffect } from 'react';
import { supabase } from '../lib/supabase';
import { Product } from '../store/useStore';

export const useProducts = (categoryId?: string | null, featured?: boolean) => {
  const [products, setProducts] = useState<Product[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchProducts = async () => {
      try {
        setLoading(true);
        let query = supabase
          .from('products')
          .select(`
            *,
            categories (
              id,
              name,
              description
            )
          `)
          .order('created_at', { ascending: false });

        if (categoryId) {
          query = query.eq('category_id', categoryId);
        }

        if (featured) {
          query = query.eq('is_featured', true);
        }

        const { data, error } = await query;

        if (error) {
          setError(error.message);
        } else {
          setProducts(data || []);
        }
      } catch (err) {
        setError('Failed to fetch products');
      } finally {
        setLoading(false);
      }
    };

    fetchProducts();
  }, [categoryId, featured]);

  return { products, loading, error };
};

export const useProduct = (id: string) => {
  const [product, setProduct] = useState<Product | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchProduct = async () => {
      try {
        setLoading(true);
        const { data, error } = await supabase
          .from('products')
          .select(`
            *,
            categories (
              id,
              name,
              description
            )
          `)
          .eq('id', id)
          .single();

        if (error) {
          setError(error.message);
        } else {
          setProduct(data);
        }
      } catch (err) {
        setError('Failed to fetch product');
      } finally {
        setLoading(false);
      }
    };

    if (id) {
      fetchProduct();
    }
  }, [id]);

  return { product, loading, error };
};